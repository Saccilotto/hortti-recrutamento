# ============================================
# General Variables
# ============================================
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "hortti-inventory"
}

# ============================================
# AWS Variables
# ============================================
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for EC2"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key content"
  type        = string
  sensitive   = true
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH into the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Recomendado: restringir ao seu IP
}

# ============================================
# Cloudflare Variables
# ============================================
variable "cloudflare_api_token" {
  description = "Cloudflare API Token with DNS edit permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
}

variable "domain_name" {
  description = "Main domain name (e.g., cantinhoverde.app.br)"
  type        = string
  default     = "cantinhoverde.app.br"
}

variable "frontend_subdomain" {
  description = "Subdomain for frontend (empty for root domain)"
  type        = string
  default     = ""
}

variable "backend_subdomain" {
  description = "Subdomain for backend API"
  type        = string
  default     = "api"
}

variable "traefik_subdomain" {
  description = "Subdomain for Traefik dashboard"
  type        = string
  default     = "traefik"
}
