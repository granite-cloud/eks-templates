variable "cidr" {
  description = "VPC Cidr"
  type        = string
  default     = "10.200.0.0/16"
}

variable "cluster" {
  description = "The name of the cluster"
  type        = string
}

variable "environment" {
  description = "The name of the environment"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "owner of the resource that will be used as a tag. (required standard tag)"
  type        = string
  default     = "granite-cloud"
}

variable "priv_subnets" {
  description = "VPC Cidr"
  default     = ["10.200.1.0/24","10.200.2.0/24","10.200.3.0/24"]
}


variable "project" {
  description = "Name of the project that will be used as a tag on all resources. (required standard tag)"
  type        = string
  default     = "dev-testing"
}

variable "pub_subnets" {
  description = "VPC Cidr"
  default     = ["10.200.4.0/24","10.200.5.0/24","10.200.6.0/24"]
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "add hashmap of extra tags to be provisioned for all asg hosts"
  type        = map
  default     = {}
}
