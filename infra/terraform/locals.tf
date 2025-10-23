# ============================================
# Local Values
# ============================================
locals {
  # Domain names
  frontend_domain = var.frontend_subdomain == "" ? var.domain_name : "${var.frontend_subdomain}.${var.domain_name}"
  backend_domain  = "${var.backend_subdomain}.${var.domain_name}"
  traefik_domain  = "${var.traefik_subdomain}.${var.domain_name}"

  # Common tags
  common_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
