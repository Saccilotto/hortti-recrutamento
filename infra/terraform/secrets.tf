# ============================================
# Terraform-managed Secrets
# ============================================
# Gera automaticamente secrets que seriam GitHub Secrets
# ============================================

# ============================================
# SSH Key Pair
# ============================================
resource "tls_private_key" "hortti_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "hortti_key" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.hortti_ssh.public_key_openssh

  tags = {
    Name        = "${var.project_name}-${var.environment}-key"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# ============================================
# Database Password
# ============================================
resource "random_password" "postgres_password" {
  length  = 32
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ============================================
# JWT Secrets
# ============================================
resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

resource "random_password" "jwt_refresh_secret" {
  length  = 64
  special = false
}

# ============================================
# Traefik Dashboard Password
# ============================================
resource "random_password" "traefik_password" {
  length  = 24
  special = true
  override_special = "!@#%&*-_=+?"
}

# Generate htpasswd hash using bcrypt
resource "null_resource" "traefik_htpasswd" {
  triggers = {
    password = random_password.traefik_password.result
  }

  provisioner "local-exec" {
    command = "docker run --rm httpd:2.4-alpine htpasswd -nbB admin '${random_password.traefik_password.result}' > ${path.module}/.traefik_auth"
  }
}

data "local_file" "traefik_auth" {
  filename   = "${path.module}/.traefik_auth"
  depends_on = [null_resource.traefik_htpasswd]
}

# ============================================
# Store secrets in SSM Parameter Store (optional)
# ============================================
resource "aws_ssm_parameter" "postgres_password" {
  name        = "/${var.project_name}/${var.environment}/postgres/password"
  description = "PostgreSQL password for ${var.project_name}"
  type        = "SecureString"
  value       = random_password.postgres_password.result

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "jwt_secret" {
  name        = "/${var.project_name}/${var.environment}/jwt/secret"
  description = "JWT secret for ${var.project_name}"
  type        = "SecureString"
  value       = random_password.jwt_secret.result

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "jwt_refresh_secret" {
  name        = "/${var.project_name}/${var.environment}/jwt/refresh-secret"
  description = "JWT refresh secret for ${var.project_name}"
  type        = "SecureString"
  value       = random_password.jwt_refresh_secret.result

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "ssh_private_key" {
  name        = "/${var.project_name}/${var.environment}/ssh/private-key"
  description = "SSH private key for ${var.project_name}"
  type        = "SecureString"
  value       = tls_private_key.hortti_ssh.private_key_pem

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "traefik_password" {
  name        = "/${var.project_name}/${var.environment}/traefik/password"
  description = "Traefik dashboard password for ${var.project_name}"
  type        = "SecureString"
  value       = random_password.traefik_password.result

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "traefik_dashboard_auth" {
  name        = "/${var.project_name}/${var.environment}/traefik/dashboard-auth"
  description = "Traefik dashboard auth (htpasswd) for ${var.project_name}"
  type        = "SecureString"
  value       = trimspace(data.local_file.traefik_auth.content)

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
