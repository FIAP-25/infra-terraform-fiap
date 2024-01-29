################################################################################
# AWS
################################################################################

variable "region" {
  description = "The region in which the resource exists"
  default     = "us-east-1"
  type        = string
}

################################################################################
# VPC
################################################################################

variable "create_vpc" {
  description = "Controls if VPC should be created"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC."
  default     = "10.0.0.0/16"
  type        = string
}

################################################################################
# Subnets
################################################################################

variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.0.128.0/20", "10.0.144.0/20"]
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

################################################################################
# RDS
################################################################################

variable "engine" {
  description = "The database engine."
  type        = string
  default     = "mysql"
}
variable "engine_version" {
  description = "The engine version."
  default     = "5.7"
  type        = number
}
variable "allocated_storage" {
  description = "The amount of allocated storage."
  type        = number
  default     = 20
}
variable "storage_type" {
  description = "type of the storage."
  type        = string
  default     = "gp2"
}
variable "instance_class" {
  description = "The RDS instance class."
  default     = "db.t2.micro"
  type        = string
}
variable "db_name" {
  description = "The database name"
  default     = "fiap"
  type        = string
}
variable "username" {
  description = "Username for the master DB user."
  default     = "root"
  type        = string
}
variable "password" {
  description = "password of the database."
  default     = "root1234"
  type        = string
}
variable "port" {
  description = "The port on which the DB accepts connections"
  default     = "3306"
  type        = number
}
variable "skip_final_snapshot" {
  description = "skip snapshot"
  default     = "true"
  type        = string
}

variable "publicly_accessible" {
  description = "Publicly accessible"
  default     = false
  type        = bool
}

variable "identifier" {
  description = "Instance Identifier"
  default     = "fiap-db"
  type        = string
}

################################################################################
# ECS
################################################################################

variable "container_image_producao" {
  type    = string
  default = "apl-producao-back:latest"
}
variable "container_image_pedido" {
  type    = string
  default = "apl-pedido-back:latest"
}
variable "container_image_pagamento" {
  type    = string
  default = "apl-pagamento-back:latest"
}

################################################################################
# Policy
################################################################################

variable "iam_policy_arn" {
  type = list(any)
  default = [
    "arn:aws:iam::752668384491:policy/DefaultPolicy"
  ]
}
