##########
# VPC
##########
variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_name" {
  description = "The name of the vpc to use in a data source to allow access to metadata"
  type        = string
}
