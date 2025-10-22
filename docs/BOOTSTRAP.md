# Terraform Backend Bootstrap

## Problem

Terraform remote state backend requires an S3 bucket and DynamoDB table to exist **before** running `terraform init`. This creates a chicken-and-egg problem on first deployment.

## Solution

The `bootstrap-backend.sh` script creates the required AWS infrastructure:

- **S3 Bucket**: `hortti-terraform-state` (with versioning, encryption, and public access block)
- **DynamoDB Table**: `hortti-terraform-locks` (for state locking)

## Usage

### Option 1: Manual Bootstrap (Local)

```bash
cd infra/terraform

# Ensure AWS credentials are configured
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_REGION="us-east-2"

# Run bootstrap script (idempotent - safe to run multiple times)
./bootstrap-backend.sh

# Now you can initialize Terraform
terraform init
```

### Option 2: Automatic Bootstrap (GitHub Actions)

The deploy workflow automatically runs the bootstrap script before `terraform init`. No manual intervention needed.

The bootstrap step is idempotent - it checks if resources exist before creating them, so it's safe to run on every deployment.

## What Gets Created

### S3 Bucket Configuration

- **Name**: `hortti-terraform-state`
- **Region**: `us-east-2`
- **Versioning**: Enabled (keeps history of state files)
- **Encryption**: AES256 server-side encryption
- **Public Access**: Blocked (security best practice)

### DynamoDB Table Configuration

- **Name**: `hortti-terraform-locks`
- **Key Schema**: `LockID` (String, Hash Key)
- **Billing**: Pay-per-request (cost-effective for low-frequency locking)
- **Purpose**: Prevents concurrent Terraform operations

## Cost Estimate

- **S3 Bucket**: ~$0.023/GB/month (minimal - only stores tfstate files)
- **DynamoDB**: ~$0.00013/read, $0.00065/write (only during terraform operations)
- **Expected monthly cost**: < $1 USD for typical usage

## Cleanup

To remove the backend infrastructure (only do this if destroying the entire project):

```bash
# Remove all state file versions from S3
aws s3 rm s3://hortti-terraform-state --recursive

# Delete S3 bucket
aws s3api delete-bucket \
  --bucket hortti-terraform-state \
  --region us-east-2

# Delete DynamoDB table
aws dynamodb delete-table \
  --table-name hortti-terraform-locks \
  --region us-east-2
```

**Warning**: Deleting the S3 bucket will permanently delete all Terraform state history. Only do this if you're completely destroying the project.

## Troubleshooting

### Error: "Bucket already exists"

This is normal if running bootstrap multiple times. The script checks existence and skips creation.

### Error: "Access Denied"

Ensure your AWS credentials have these permissions:

- `s3:CreateBucket`
- `s3:PutBucketVersioning`
- `s3:PutBucketEncryption`
- `s3:PutBucketPublicAccessBlock`
- `dynamodb:CreateTable`
- `dynamodb:DescribeTable`

### Error: "Region mismatch"

The script hardcodes `us-east-2`. If you need a different region, update both:

1. `bootstrap-backend.sh` (AWS_REGION variable)
2. `versions.tf` (backend.s3.region)
