# ============================================
# VPC and Network Resources
# ============================================
# Simple VPC for single-node deployment
# ============================================

# ============================================
# VPC
# ============================================
resource "aws_vpc" "hortti_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
    }
  )
}

# ============================================
# Internet Gateway
# ============================================
resource "aws_internet_gateway" "hortti_igw" {
  vpc_id = aws_vpc.hortti_vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}

# ============================================
# Public Subnet
# ============================================
resource "aws_subnet" "hortti_public_subnet" {
  vpc_id                  = aws_vpc.hortti_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-subnet"
      Type = "public"
    }
  )
}

# ============================================
# Route Table
# ============================================
resource "aws_route_table" "hortti_public_rt" {
  vpc_id = aws_vpc.hortti_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hortti_igw.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-rt"
    }
  )
}

# ============================================
# Route Table Association
# ============================================
resource "aws_route_table_association" "hortti_public_rta" {
  subnet_id      = aws_subnet.hortti_public_subnet.id
  route_table_id = aws_route_table.hortti_public_rt.id
}
