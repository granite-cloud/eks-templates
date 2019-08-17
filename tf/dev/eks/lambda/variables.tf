variable "cluster" {
  description = "The name of the cluster"
  type        = string
  default     = "granite-cloud"
}

variable "environment" {
  description = "The name of the environment"
  type        = string
  default     = "dev"
}

variable "function_name" {
  description = "The name of the lambda fucntion to invoke"
  type        = string
  default     = "eks-bootstrap"
}

variable "instance_types" {
  description = "The name of the environment"
  type        = string
  default     = "t2.small,t3.small,t3.medium"
}

variable "owner" {
  description = "owner of the resource that will be used as a tag. (required standard tag)"
  type        = string
  default     = "granite-cloud"
}


variable "project" {
  description = "Name of the project that will be used as a tag on all resources. (required standard tag)"
  type        = string
  default     = "dev-testing"
}


variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
