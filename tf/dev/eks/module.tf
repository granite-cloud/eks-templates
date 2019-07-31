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
  backend "s3" {
    key    = "dev/eks/eks.tfstate"
    bucket = "granite-terraform-state"
  }
}

############
# Shared Data
############
module "data" {
   source         = "../../data_source"
   vpc_name       = var.vpc_name
   region         = var.region
}

######
# EKS Cluster / Worker Nodes
######
module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = var.cluster
  subnets      = module.data.all_subnets
  vpc_id       = module.data.vpc_id
  map_users     = var.map_users

  worker_groups_launch_template_mixed = [
    {
      autoscaling_enabled      = var.enable_autoscale
      protect_from_scale_in    = var.enable_scalein_protect
      key_name                 = var.key
      name                     = var.worker_name
      override_instance_types  = var.override_types
      spot_instance_pools      = var.spot_instance_pools
      asg_max_size             = var.max_size
      asg_desired_capacity     = var.desired_capacity
      kubelet_extra_args       = var.spot_kube_args
      public_ip                = var.pub_ip
      subnets                  = [module.data.private_subnets[0]]
    },
  ]

  worker_groups_launch_template = [
    {
      name                   = "worker-group-1"
      autoscaling_enabled    = var.enable_autoscale
      protect_from_scale_in  = var.enable_scalein_protect
      key_name               = var.key
      instance_type          = "t2.small"
      asg_desired_capacity   = 1
      asg_max_size           = var.max_size
      public_ip              = false
      kubelet_extra_args     = var.demand_kube_args
      subnets                = [module.data.private_subnets[1]]
   },
   {
      name                   = "worker-group-2"
      autoscaling_enabled    = var.enable_autoscale
      key_name               = var.key
      protect_from_scale_in  = var.enable_scalein_protect
      instance_type          = "t2.small"
      asg_desired_capacity   = 1
      asg_max_size           = var.max_size
      public_ip              = false
      kubelet_extra_args     = var.demand_kube_args
      subnets                = [module.data.private_subnets[2]]
   },
  ]

 }
