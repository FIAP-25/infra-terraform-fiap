locals {
  create_vpc             = var.create_vpc
  create_public_subnets  = var.create_vpc
  create_private_subnets = var.create_vpc
  create_igw             = var.create_vpc
  vcp_id                 = try(aws_vpc.vpc[0].id, "")
}


################################################################################
# VPC
################################################################################
resource "aws_vpc" "vpc" {
  count                = local.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-fiap"
  }
}

################################################################################
# Subnets
################################################################################
resource "aws_subnet" "private_subnet" {
  count                   = local.create_private_subnets ? length(var.private_subnets_cidr) : 0
  vpc_id                  = local.vcp_id
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public_subnet" {
  count                   = local.create_public_subnets ? length(var.public_subnets_cidr) : 0
  vpc_id                  = local.vcp_id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
}

################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "igw" {
  count  = local.create_public_subnets ? 1 : 0
  vpc_id = local.vcp_id
}

################################################################################
# Routes
################################################################################
resource "aws_route_table" "private" {
  count  = local.create_private_subnets ? 1 : 0
  vpc_id = local.vcp_id
}

resource "aws_route_table_association" "private" {
  count          = local.create_private_subnets ? length(var.private_subnets_cidr) : 0
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table" "public" {
  count  = local.create_public_subnets ? 1 : 0
  vpc_id = local.vcp_id
}

resource "aws_route_table_association" "public" {
  count          = local.create_public_subnets ? length(var.private_subnets_cidr) : 0
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route" "public_internet_gateway" {
  count                  = local.create_public_subnets && local.create_igw ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}


