variable "ecr_repo" {
  description = "The name of the ecr rerpo"
  type        = string
}

variable "environment" {
  description = "The name of the environment"
  type        = string
}

variable "git_branch" {
  description = "Github repo branch"
  type        = string
}

variable "git_owner" {
  description = "Github repo owner"
  type        = string
}

variable "git_token" {
  description = "Github Token used for Source stage"
  type        = string
}

variable "git_repo" {
  description = "Github repo name"
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
