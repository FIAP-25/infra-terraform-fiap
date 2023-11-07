variable "aws_access_key" {}
variable "aws_secret_key" {}


provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

// virtual private cloud
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

// private subnet from vpc 
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

// public subnet from vpc
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_security_group" "private_rds_sg" {
  name = "private-rds-security-group"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "private_ecs_sg" {
  name = "private-ecs-security-group"
  vpc_id = aws_vpc.main.id

  // Permite inboud do public_ecs_sg
  ingress {
    from_port   = 3000 // Node.js default port
    to_port     = 3000 // Node.js default port
    protocol    = "tcp"
    security_groups = [aws_security_group.public_ecs_sg.id] 
  }

  // Permite outbound para o private_rds_sg
  egress {
    from_port   = 3306 // MySQL default port
    to_port     = 3306 // MySQL default port
    protocol    = "tcp"
    security_groups = [aws_security_group.private_rds_sg.id]
  }
}

resource "aws_security_group" "public_ecs_sg" {
  name = "public-ecs-security-group"
  vpc_id = aws_vpc.main.id

   // Permite inbound da internet
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
