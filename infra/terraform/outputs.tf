# ============================================
# EC2 Outputs
# ============================================
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.hortti_app.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.hortti_app.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.hortti_app.public_dns
}

# ============================================
# VPC Outputs
# ============================================
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.hortti_vpc.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.hortti_public_subnet.id
}

# ============================================
# Security Group Outputs
# ============================================
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.hortti_sg.id
}

# ============================================
# Domain Outputs
# ============================================
output "frontend_url" {
  description = "Frontend URL"
  value       = "https://${local.frontend_domain}"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "https://${local.backend_domain}"
}

output "traefik_dashboard_url" {
  description = "Traefik Dashboard URL"
  value       = "https://${local.traefik_domain}"
}

# ============================================
# SSH Command
# ============================================
output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.ssh_key_name}.pem ubuntu@${aws_instance.hortti_app.public_ip}"
}

# ============================================
# Ansible Inventory
# ============================================
output "ansible_host" {
  description = "Host for Ansible inventory"
  value       = aws_instance.hortti_app.public_ip
}

# ============================================
# Generated Secrets (for Ansible)
# ============================================
output "ssh_private_key" {
  description = "SSH private key for Ansible"
  value       = tls_private_key.hortti_ssh.private_key_pem
  sensitive   = true
}

output "postgres_password" {
  description = "PostgreSQL password"
  value       = random_password.postgres_password.result
  sensitive   = true
}

output "jwt_secret" {
  description = "JWT secret"
  value       = random_password.jwt_secret.result
  sensitive   = true
}

output "jwt_refresh_secret" {
  description = "JWT refresh secret"
  value       = random_password.jwt_refresh_secret.result
  sensitive   = true
}

# ============================================
# Hardcoded values (for Ansible)
# ============================================
output "postgres_user" {
  description = "PostgreSQL username"
  value       = "hortti_admin"
}

output "postgres_db" {
  description = "PostgreSQL database name"
  value       = "hortti_inventory"
}

output "acme_email" {
  description = "Email for Let's Encrypt"
  value       = "admin@cantinhoverde.app.br"
}

output "traefik_password" {
  description = "Traefik dashboard password (username: admin)"
  value       = random_password.traefik_password.result
  sensitive   = true
}

output "traefik_dashboard_auth" {
  description = "Traefik dashboard auth (htpasswd format)"
  value       = trimspace(data.local_file.traefik_auth.content)
  sensitive   = true
}
