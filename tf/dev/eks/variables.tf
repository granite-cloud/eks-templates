variable "cluster" {
  description = "The name of the cluster"
  type        = string
}

variable "desired_capacity" {
  description = "Desired size of autoscale group"
  type        = number
  default     = 1
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

variable "key" {
  description = "Name of keypair to allow access to worker nodes"
  type        = string
}

variable "spot_kube_args" {
  description = "This string is passed directly to kubelet if set. Useful for adding labels or taints."
  type        = string
  default     = "--node-labels=spotfleet=yes --register-with-taints=spotInstance=true:PreferNoSchedule"
}

variable "demand_kube_args" {
  description = "This string is passed directly to kubelet if set. Useful for adding labels or taints."
  type        = string
  default     = "--kubelet-extra-args --node-labels=ondemand=yes"
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

variable "max_size" {
  description = "Max size of autoscale group"
  type        = number
  default     = 2
}

variable "override_types" {
  description = "Worker node launch config override instance type used for mixed instance policy"
  type        = list
  default     = ["t2.small","t3.small","t3.medium"]
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
