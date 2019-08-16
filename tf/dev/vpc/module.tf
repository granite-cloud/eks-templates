####################
# Instead of inputing values in interaction, you can use direnv and .envrc file for providing configuration.
# https://registry.terraform.io/modules/literalice/openshift/aws/0.0.2
#
# Example of setting backend
# export TF_CLI_ARGS_init="-backend-config='bucket=granite-terraform-state'"
# export TF_CLI_ARGS_init="$TF_CLI_ARGS_init -backend-config='key=dev/vpc/vpc.tfstate'"
# export TF_CLI_ARGS_init="$TF_CLI_ARGS_init -backend-config='region=us-east-1'"
#
# Above could be exported by a CI server (Jenkins...) as a part of provisioning infrastructure. The configs
# could be build parameters...
####################
terraform {
  required_version = ">= 0.12"
  backend "s3" {
    key    = "dev/vpc/vpc.tfstate"
    bucket = "granite-terraform-state"
  }
}

############
# VPC
############
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>v2.0"

  name = "${var.environment}-ECS"
  cidr = var.cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.priv_subnets
  public_subnets  = var.pub_subnets
  private_subnet_tags = {
    "Tier"                            = "Private",
    "kubernetes.io/role/internal-elb" = "1"
  }
  public_subnet_tags = {
    "Tier"                   = "Public",
    "kubernetes.io/role/elb" = "1"
  }

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(local.common_tags, local.extra_tags)
}
