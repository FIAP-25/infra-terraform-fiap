locals {
  publicly_accessible = var.publicly_accessible
}

data "http" "myip" {
  url = "https://checkip.amazonaws.com/"
}

resource "aws_db_subnet_group" "rds" {
  name       = "subnet_group_rds"
  subnet_ids = local.publicly_accessible ? aws_subnet.public_subnet.*.id : aws_subnet.private_subnet.*.id
}

resource "aws_security_group" "rds" {
  name        = "fiap-sg-rds"
  description = "Security Group for RDS"
  vpc_id      = local.vcp_id

  ingress = [{
    cidr_blocks      = ["${chomp(data.http.myip.response_body)}/32"]
    description      = "Connection MySQL Workbench"
    from_port        = 3306
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 3306
    }, {
    cidr_blocks      = []
    description      = "Self Connection"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = true
    to_port          = 0
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Connection Output"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
}

resource "aws_db_instance" "default" {
  engine              = var.engine
  engine_version      = var.engine_version
  allocated_storage   = var.allocated_storage
  storage_type        = var.storage_type
  instance_class      = var.instance_class
  identifier          = var.identifier
  db_name             = var.db_name
  username            = var.username
  password            = var.password
  port                = var.port
  skip_final_snapshot = var.skip_final_snapshot
  publicly_accessible = local.publicly_accessible

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name
}
