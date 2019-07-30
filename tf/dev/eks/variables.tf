variable "cluster" {
  description = "The name of the cluster"
  type        = string
}

variable "desired_capacity" {
  description = "Desired size of autoscale group"
  type        = numbers
  default     = 3
}

variable "environment" {
  description = "The name of the environment"
  type        = string
}

variable "kube_args" {
  description = "This string is passed directly to kubelet if set. Useful for adding labels or taints."
  type        = string
  default     = "--node-labels=kubernetes.io/lifecycle=spot"
}


variable "max_size" {
  description = "Max size of autoscale group"
  type        = numbers
  default     = 3
}

variable "override_types" {
  description = "Worker node launch config override instance type used for mixed instance policy"
  type        = list
}

variable "pub_ip" {
  description = "Associate a public ip address with a worker"
  type        = bool
  default     = false
}

variable "pub_subnets" {
  description = "Public subnets"
  type        = list
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

variable "vpc_id" {
  description = "The VPC id"
  type        = string
}

variable "worker_name" {
  description = "Name of the worker group."
  type        = string
}
