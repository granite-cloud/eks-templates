variable "cluster" {
  description = "The name of the cluster"
  type        = string
}

variable "demand_max_size" {
  description = "Max size of autoscale group"
  type        = number
  default     = 3
}

variable "demand_min_size" {
  description = "Min size of autoscale group"
  type        = number
  default     = 0
}

variable "demand_desired_capacity" {
  description = "Desired size of autoscale group"
  type        = number
  default     = 0
}

variable "environment" {
  description = "The name of the environment"
  type        = string
}

variable "enable_autoscale" {
  description = "Sets whether policy and matching tags will be added to allow autoscaling."
  type        = bool
}

variable "enable_scalein_protect" {
  description = "Prevent AWS from scaling in, so that cluster-autoscaler is solely responsible."
  type        = bool
}

variable "instance_type" {
  description = "On demand instance type."
  type        = string
  default     = "t3.small"
}

variable "key" {
  description = "Name of keypair to allow access to worker nodes"
  type        = string
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type        = list(map(string))

  default = [
    {
      role_arn = "arn:aws:iam::627177891842:role/AmazonEKSAdminRole"
      username = "AmazonEKSAdminRole"
      group    = "system:masters"
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type        = list(map(string))

  default = [
    {
      user_arn = "arn:aws:iam::627177891842:user/playground"
      username = "playground"
      group    = "system:masters"
    }
  ]
}

variable "override_types" {
  description = "Worker node launch config override instance type used for mixed instance policy"
  type        = list
  default     = ["t2.medium", "t3.medium"]
}

variable "pub_ip" {
  description = "Associate a public ip address with a worker"
  type        = bool
  default     = false
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity"
  type        = number
  default     = 3
}

variable "spot_max_size" {
  description = "Max size of autoscale group"
  type        = number
  default     = 3
}

variable "spot_min_size" {
  description = "Min size of autoscale group"
  type        = number
  default     = 1
}

variable "spot_desired_capacity" {
  description = "Desired size of autoscale group"
  type        = number
  default     = 1
}

variable "vpc_name" {
  description = "The name of the vpc to use in a data source to allow access to metadata"
  type        = string
  default     = "dev-ECS"
}

variable "worker_name" {
  description = "Name of the worker group."
  type        = string
  default     = "granite"
}
