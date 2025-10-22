#!/bin/bash
set -e

# Configuration
BUCKET_NAME="hortti-terraform-state"
DYNAMODB_TABLE="hortti-terraform-locks"
AWS_REGION="us-east-2"

echo "🚀 Bootstrapping Terraform backend infrastructure..."

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "❌ Error: AWS CLI is not installed"
    exit 1
fi

# Check if bucket already exists
if aws s3 ls "s3://${BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "📦 Creating S3 bucket: ${BUCKET_NAME}"

    # Create bucket
    aws s3api create-bucket \
        --bucket "${BUCKET_NAME}" \
        --region "${AWS_REGION}" \
        --create-bucket-configuration LocationConstraint="${AWS_REGION}"

    # Enable versioning
    echo "🔄 Enabling versioning on S3 bucket..."
    aws s3api put-bucket-versioning \
        --bucket "${BUCKET_NAME}" \
        --versioning-configuration Status=Enabled

    # Enable encryption
    echo "🔒 Enabling encryption on S3 bucket..."
    aws s3api put-bucket-encryption \
        --bucket "${BUCKET_NAME}" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'

    # Block public access
    echo "🛡️  Blocking public access on S3 bucket..."
    aws s3api put-public-access-block \
        --bucket "${BUCKET_NAME}" \
        --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

    echo "✅ S3 bucket created successfully"
else
    echo "✅ S3 bucket already exists: ${BUCKET_NAME}"
fi

# Check if DynamoDB table already exists
if aws dynamodb describe-table --table-name "${DYNAMODB_TABLE}" --region "${AWS_REGION}" 2>&1 | grep -q 'ResourceNotFoundException'; then
    echo "🗄️  Creating DynamoDB table: ${DYNAMODB_TABLE}"

    aws dynamodb create-table \
        --table-name "${DYNAMODB_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "${AWS_REGION}" \
        --tags Key=Project,Value="Hortti Inventory" \
               Key=ManagedBy,Value=Terraform \
               Key=Purpose,Value="State Locking"

    echo "⏳ Waiting for DynamoDB table to be active..."
    aws dynamodb wait table-exists \
        --table-name "${DYNAMODB_TABLE}" \
        --region "${AWS_REGION}"

    echo "✅ DynamoDB table created successfully"
else
    echo "✅ DynamoDB table already exists: ${DYNAMODB_TABLE}"
fi

echo ""
echo "🎉 Backend infrastructure is ready!"
echo "📋 Summary:"
echo "   - S3 Bucket: ${BUCKET_NAME} (${AWS_REGION})"
echo "   - DynamoDB Table: ${DYNAMODB_TABLE}"
echo ""
echo "You can now run: terraform init"
