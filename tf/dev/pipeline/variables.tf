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

variable "git_token" {
  description = "Github Token used for Source stage"
  type        = string
}

variable "image_tag" {
  description = "The tag for the image in ecr"
  type        = string
  default     = "1.2"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
