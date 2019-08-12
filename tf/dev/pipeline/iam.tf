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
     sid    = "AllowECRLogin"
     effect = "Allow"
     actions = ["ecr:GetAuthorizationToken"]
     resources = ["*"]
  }

  statement {
     sid    = "AllowAssumeKubeRole"
     effect = "Allow"
     actions = [
       "sts:AssumeRole",
       "iam:GetRole"
     ]
     resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKSAdminRole"]
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
    resources = ["arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_repo}"]
  }
}

resource "aws_iam_role_policy" "codebuild" {
  role   = "${aws_iam_role.codebuild.name}"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}

###########
# Lambda IAM Role / Policies
#
# Note: Since I am using a public module for lambda, I only need to provide
# additional IAM policy rules here. The basics with logging and other options are
# provided by the public module.
# I have left the structure intact , commented out, so that there is an option to
# use our own logic to create the lambda if desired
###########

/*

data "aws_iam_policy_document" "assume_by_CodeBuildLambda" {
  statement {
    sid     = "AllowAssumeByLambda"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "CodebuildLambda" {
  name               = "CodeBuildRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_CodeBuildLambda.json}"
}

*/

data "aws_iam_policy_document" "CodebuildLambda" {
  statement {
    sid    = "AllowIAMUpdate"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKSAdminRole"]
  }
}

/*
resource "aws_iam_role_policy" "CodebuildLambda" {
  role   = "${aws_iam_role.CodebuildLambda.name}"
  policy = "${data.aws_iam_policy_document.CodebuildLambda.json}"
}

# Data source to allow reference of a the managed IAM policy
data "aws_iam_policy" "LambdaExecution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach the aws managed Lambda policy
resource "aws_iam_role_policy_attachment" "this" {
    role = aws_iam_role.CodebuildLambda.name
    policy_arn = data.aws_iam_policy.LambdaExecution.arn
}
*/
