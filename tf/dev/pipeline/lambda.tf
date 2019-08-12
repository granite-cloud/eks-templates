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


############
# Invoke Lambda that will install cluster autoscaler
############
data "aws_lambda_invocation" "update_iam_configmap" {
  function_name = "codebuild-update-iam"
  input = <<JSON
{
  "KubectlRoleName": "AmazonEKSAdminRole",
  "CodeBuildServiceRoleArn": "${aws_iam_role.codebuild.arn}"
}
JSON

}

output "result" {
  description = "String result of Lambda execution"
  value       = "${data.aws_lambda_invocation.update_iam_configmap.result}"
}
