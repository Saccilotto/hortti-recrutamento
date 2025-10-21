#!/bin/bash
set -e

# ============================================
# Initial Setup for Ubuntu EC2 Instance
# ============================================

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Install Docker Compose
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Install useful tools
apt-get install -y \
    git \
    curl \
    wget \
    vim \
    htop \
    make \
    python3 \
    python3-pip \
    python3-venv

# Configure firewall (ufw)
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS

# Create application directory
mkdir -p /opt/hortti-inventory
chown -R ubuntu:ubuntu /opt/hortti-inventory

# Enable Docker service
systemctl enable docker
systemctl start docker

# Create swap file (recommended for t2.medium)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Configure log rotation for Docker
cat > /etc/logrotate.d/docker-container << EOF
/var/lib/docker/containers/*/*.log {
  rotate 7
  daily
  compress
  size=10M
  missingok
  delaycompress
  copytruncate
}
EOF

# Reboot to apply all changes
echo "Initial setup complete. System will reboot in 10 seconds..."
sleep 10
reboot
