data "aws_availability_zones" "azs" {}

module "recruit-vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = "recruit-vpc"
  cidr            = var.vpc_cidr_block
  private_subnets = var.recruit_private_subnet_cidr_blocks
  public_subnets  = var.recruit_public_subnet_cidr_blocks
  azs             = data.aws_availability_zones.azs.names

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/recruiters-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/recruiters-cluster" = "shared"
    "kubernetes.io/role/elb"                = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/recruiters-cluster" = "shared"
    "kubernetes.io/role/internal-elb"       = 1
  }
}
