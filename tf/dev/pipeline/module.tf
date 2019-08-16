#####################
# CodePipeline EKS
#####################



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
  required_version = ">= 0.12"
  backend "s3" {
    key    = "dev/eks-pipeline/eks-pipeline.tfstate"
    bucket = "granite-terraform-state"
  }
}

#####################
# S3 artifact bucket
#####################
resource "aws_s3_bucket" "this" {
  bucket        = "ecs-app-codepipeline"
  force_destroy = true
}

#####################
# CodeBuild Project
#####################
resource "aws_codebuild_project" "this" {
  name         = "eks-codebuild"
  description  = "Codebuild for EKS GO test app"
  service_role = "${aws_iam_role.codebuild.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:18.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo}"
    }

    environment_variable {
      name  = "ECR_REPO"
      value = "${var.ecr_repo}"
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = "granite-cloud"
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.cluster
    }

    environment_variable {
      name  = "EKS_KUBECTL_ROLE_ARN"
      value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKSAdminRole"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = var.image_tag
    }
  }
  source {
    type = "CODEPIPELINE"
  }
}

#####################
# CodePipeline
#####################
resource "aws_codepipeline" "this" {
  name     = "eks-pipeline"
  role_arn = "${aws_iam_role.pipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.this.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        OAuthToken = var.git_token
        Owner      = var.git_owner
        Repo       = var.git_repo
        Branch     = var.git_branch
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]

      configuration = {
        ProjectName = "${aws_codebuild_project.this.name}"
      }
    }
  }
}
