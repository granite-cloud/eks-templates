#####################
# CodeBuild / CodePipeline IAM Resources
#####################

###########
# Pipeline IAM Role / Policies
###########
data "aws_iam_policy_document" "assume_by_pipeline" {
  statement {
    sid     = "AllowAssumeByPipeline"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pipeline" {
  name               = "CodePipelineRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_pipeline.json}"
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.this.arn}",
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

  statement {
    sid    = "AllowCodeBuild"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = ["${aws_codebuild_project.this.arn}"]
  }

  statement {
    sid    = "AllowPassRole"
    effect = "Allow"
    resources = ["*"]
    actions = ["iam:PassRole"]
  }
}

resource "aws_iam_role_policy" "pipeline" {
  role   = "${aws_iam_role.pipeline.name}"
  policy = "${data.aws_iam_policy_document.pipeline.json}"
}


###########
# Build IAM Role / Policies
###########
data "aws_iam_policy_document" "assume_by_codebuild" {
  statement {
    sid     = "AllowAssumeByCodebuild"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "CodeBuildRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_codebuild.json}"
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.this.arn}",
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

  statement {
    sid    = "AllowLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

 statement {
    sid    = "AllowEKSDescribe"
    effect = "Allow"
    actions = ["eks:Describe*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowECRUpload"
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
    ]
    resources = ["${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo}"]
  }

  statement {
    sid    = "AllowLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild" {
  role   = "${aws_iam_role.codebuild.name}"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}
