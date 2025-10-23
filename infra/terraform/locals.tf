# ============================================
# Local Values
# ============================================
locals {
  # Domain names
  frontend_domain = var.frontend_subdomain == "" ? var.domain_name : "${var.frontend_subdomain}.${var.domain_name}"
  backend_domain  = "${var.backend_subdomain}.${var.domain_name}"
  traefik_domain  = "${var.traefik_subdomain}.${var.domain_name}"

  # Traefik dashboard authentication
  # Generate random password for Traefik dashboard (username: admin)
  traefik_password = var.traefik_dashboard_password != "" ? var.traefik_dashboard_password : ""

  # Bcrypt hash for basicauth (empty string if no password set)
  # Format: admin:$apr1$... or admin:$2y$...
  traefik_dashboard_auth_bcrypt = var.traefik_dashboard_password != "" ? "admin:${bcrypt(var.traefik_dashboard_password)}" : ""

  # Common tags
  common_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
