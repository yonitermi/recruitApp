variable "vpc_cidr_block" {
  type = string
  description = "CIDR block for the recruit VPC"
}

variable "recruit_private_subnet_cidr_blocks" {
  type = list(string)
  description = "CIDR blocks for the recruit private subnets"
}

variable "recruit_public_subnet_cidr_blocks" {
  type = list(string)
  description = "CIDR blocks for the recruit public subnets"
}

variable "region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-1"  # You can change this default as needed
}
