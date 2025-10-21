terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  # Backend para armazenar state remotamente (S3)
  backend "s3" {
    bucket         = "hortti-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "hortti-terraform-locks"
  }
}
