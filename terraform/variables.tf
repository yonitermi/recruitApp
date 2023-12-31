variable "vpc_cidr_block" {
 type = string
}

variable "private_subnet_cidr_blocks" {
 type = list(string)
}

variable "public_subnet_cidr_blocks" {
 type = list(string)
}

variable "region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-1"  # You can change this default as needed
}
