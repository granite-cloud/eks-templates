module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "deployment-deploy-status"
  description   = "Deployment deploy status task"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 300

  // Specify a file or directory for the source code.
  source_path = "${path.module}/lambda.py"

  // Attach a policy.
  policy = {
    json = data.aws_iam_policy_document.lambda.json
  }
}
