module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "codebuild-update-iam"
  description   = "Update the eks admin iam role trust to allow assume by codebuild "
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 300
  source_path = "${path.module}/main.py"
  # Attache IAM Policy
  policy = {
    json = data.aws_iam_policy_document.CodebuildLambda.json
  }
}
