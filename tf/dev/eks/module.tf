####################
# Instead of inputing values in interaction, you can use direnv and .envrc file for providing configuration.
# https://registry.terraform.io/modules/literalice/openshift/aws/0.0.2
#
# Example of setting backend
# export TF_CLI_ARGS_init="-backend-config='bucket=granite-terraform-state'"
# export TF_CLI_ARGS_init="$TF_CLI_ARGS_init -backend-config='key=dev/ecs/cluster.tfstate'"
# export TF_CLI_ARGS_init="$TF_CLI_ARGS_init -backend-config='region=us-east-1'"
#
# Above could be exported by a CI server (Jenkins...) as a part of provisioning infrastructure. The configs
# could be build parameters...
####################
terraform {
  required_version = ">= 0.12"
  backend "s3" {
    key    = "dev/eks/eks.tfstate"
    bucket = "granite-terraform-state"
  }
}

############
# Shared Data
############
module "data" {
  source   = "../../data_source"
  vpc_name = var.vpc_name
  region   = var.region
}


data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data")
}

data "template_file" "bootstrap_args" {
  template = file("${path.module}/templates/extrabootstrap")
  vars = {

  }
}

######
# EKS Cluster
######
module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = var.cluster
  subnets      = module.data.all_subnets
  vpc_id       = module.data.vpc_id
  map_users    = var.map_users
  map_roles    = var.map_roles

  ###########
  # Worker Nodes
  ###########

  # Mixed instance types with spot fleet
  worker_groups_launch_template_mixed = [
    {
      asg_min_size            = var.spot_min_size
      asg_max_size            = var.spot_max_size
      asg_desired_capacity    = var.spot_desired_capacity
      autoscaling_enabled     = var.enable_autoscale
      ebs_optimized           = false
      key_name                = var.key
      kubelet_extra_args      = "--node-labels=spotfleet=yes,cluster=${var.cluster},environment=${var.environment}"
      name                    = "spot"
      override_instance_types = var.override_types
      pre_user_data           = data.template_file.user_data.rendered
      protect_from_scale_in   = var.enable_scalein_protect
      public_ip               = var.pub_ip
      spot_instance_pools     = var.spot_instance_pools
      subnets                 = module.data.private_subnets
      suspended_processes     = ["AZRebalance"] # not required after implementing lambda and life cycle hook
    },
  ]

  # On demand
  worker_groups_launch_template = [
    {
      asg_min_size          = var.demand_min_size
      asg_desired_capacity  = var.demand_desired_capacity
      asg_max_size          = var.demand_max_size
      autoscaling_enabled   = var.enable_autoscale
      instance_type         = var.instance_type
      key_name              = var.key
      kubelet_extra_args    = "--node-labels=ondemand=yes,cluster=${var.cluster},environment=${var.environment}"
      name                  = "demand"
      pre_user_data         = data.template_file.user_data.rendered
      protect_from_scale_in = var.enable_scalein_protect
      public_ip             = var.pub_ip
      subnets               = module.data.private_subnets
      suspended_processes   = ["AZRebalance"] # not required after implementing lambda and life cycle hook
    }
  ]
}
