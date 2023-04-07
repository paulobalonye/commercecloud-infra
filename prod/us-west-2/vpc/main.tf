

locals {
  available_aws_availability_zones_names = data.terraform_remote_state.aws_data.outputs.available_aws_availability_zones_names
  vpc_name                               = data.terraform_remote_state.project.outputs.prefix
  cluster_name                           = "${data.terraform_remote_state.project.outputs.prefix}-eks"
  vpc_cidr                               = "172.26.0.0/16"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = local.vpc_name

  cidr = local.vpc_cidr

  azs              = [for v in local.available_aws_availability_zones_names : v]
  public_subnets   = [for k, v in local.available_aws_availability_zones_names : cidrsubnet(local.vpc_cidr, 8, k + 0)]
  private_subnets  = [for k, v in local.available_aws_availability_zones_names : cidrsubnet(local.vpc_cidr, 8, k + 10)]
  database_subnets = [for k, v in local.available_aws_availability_zones_names : cidrsubnet(local.vpc_cidr, 8, k + 20)]

  enable_ipv6 = true

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
    "Name"                                        = "public-subnet"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    "Name"                                        = "private-subnet"
  }

  # public_subnet_tags_per_az = {
  #   "${local.region}a" = {
  #     "availability-zone" = "${local.region}a"
  #   }
  # }

  tags = data.terraform_remote_state.project.outputs.tags

  vpc_tags = {
    Name = data.terraform_remote_state.project.outputs.prefix
  }
}