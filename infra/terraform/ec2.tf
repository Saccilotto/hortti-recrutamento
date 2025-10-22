# ============================================
# EC2 Instance
# ============================================
# Note: SSH key pair is defined in secrets.tf
resource "aws_instance" "hortti_app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.hortti_key.key_name

  subnet_id              = aws_subnet.hortti_public_subnet.id
  vpc_security_group_ids = [aws_security_group.hortti_sg.id]

  # Root volume
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-root"
      }
    )
  }

  # User data for initial setup
  user_data = templatefile("${path.module}/user-data.sh", {
    domain_name = var.domain_name
  })

  # Enable detailed monitoring
  monitoring = true

  # Instance metadata options (security best practice)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-app"
    }
  )

  # Prevents instance replacement on user_data changes
  lifecycle {
    ignore_changes = [user_data]
  }
}

# ============================================
# Elastic IP (Optional but recommended)
# ============================================
resource "aws_eip" "hortti_eip" {
  instance = aws_instance.hortti_app.id
  domain   = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-eip"
    }
  )

  depends_on = [
    aws_instance.hortti_app,
    aws_internet_gateway.hortti_igw
  ]
}
