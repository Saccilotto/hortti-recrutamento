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
