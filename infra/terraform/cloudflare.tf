# ============================================
# Cloudflare DNS Records
# ============================================

# Frontend (root domain or www)
resource "cloudflare_record" "frontend" {
  zone_id = var.cloudflare_zone_id
  name    = var.frontend_subdomain == "" ? "@" : var.frontend_subdomain
  value   = aws_eip.hortti_eip.public_ip
  type    = "A"
  ttl     = 1 # Auto (Cloudflare proxy)
  proxied = false # Disable proxy for Let's Encrypt DNS challenge

  comment = "Frontend - Hortti Inventory ${var.environment}"
}

# Backend API
resource "cloudflare_record" "backend" {
  zone_id = var.cloudflare_zone_id
  name    = var.backend_subdomain
  value   = aws_eip.hortti_eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = false

  comment = "Backend API - Hortti Inventory ${var.environment}"
}

# Traefik Dashboard
resource "cloudflare_record" "traefik" {
  zone_id = var.cloudflare_zone_id
  name    = var.traefik_subdomain
  value   = aws_eip.hortti_eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = false

  comment = "Traefik Dashboard - Hortti Inventory ${var.environment}"
}

# ============================================
# Cloudflare SSL/TLS Settings
# ============================================
resource "cloudflare_zone_settings_override" "hortti_settings" {
  zone_id = var.cloudflare_zone_id

  settings {
    # SSL/TLS
    ssl = "full" # Full (strict) recommended, but requires valid cert on origin

    # Always use HTTPS
    always_use_https = "on"

    # Security
    security_level = "medium"

    # Browser cache TTL
    browser_cache_ttl = 14400

    # Challenge TTL
    challenge_ttl = 1800

    # Development mode (disable for production)
    development_mode = "off"
  }
}
