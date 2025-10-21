provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Hortti Inventory"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "hortti-recrutamento"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
