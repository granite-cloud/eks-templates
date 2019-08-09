variable "ecr_repo" {
  description = "The name of the ecr rerpo"
  type        = string
  default     = "granite-cloud"
}

variable "environment" {
  description = "The name of the environment"
  type        = string
  default     = "dev"
}

variable "image_tag" {
  description = "The tag for the image in ecr"
  type        = string
  default     = "1.0"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
