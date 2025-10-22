# ============================================
# Security Group for EC2
# ============================================
resource "aws_security_group" "hortti_sg" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for Hortti Inventory application"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # PostgreSQL (interno - apenas da própria SG)
  ingress {
    description     = "PostgreSQL (internal)"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.hortti_sg.id]
  }

  # Backend NestJS (interno - apenas da própria SG)
  ingress {
    description     = "Backend API (internal)"
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.hortti_sg.id]
  }

  # Frontend Next.js (interno - apenas da própria SG)
  ingress {
    description     = "Frontend (internal)"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.hortti_sg.id]
  }

  # Traefik Dashboard (interno - apenas da própria SG)
  ingress {
    description     = "Traefik Dashboard (internal)"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.hortti_sg.id]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-sg"
    }
  )
}
