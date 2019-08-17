####################
# Instead of inputing values in interaction, you can use direnv and .envrc file for providing configuration.
# https://registry.terraform.io/modules/literalice/openshift/aws/0.0.2
#
# Example of setting backend
# export TF_CLI_ARGS_init="-backend-config='bucket=granite-terraform-state'"
# export TF_CLI_ARGS_init="$TF_CLI_ARGS_init -backend-config='key=dev/vpc/vpc.tfstate'"
# export TF_CLI_ARGS_init="$TF_CLI_ARGS_init -backend-config='region=us-east-1'"
#
# Above could be exported by a CI server (Jenkins...) as a part of provisioning infrastructure. The configs
# could be build parameters...
####################
terraform {
  backend "s3" {
    key    = "dev/lambda/lambda.tfstate"
    bucket = "granite-terraform-state"
  }
}

############
# Invoke Lambda that will install cluster autoscaler
############
data "aws_lambda_invocation" "bootstrap" {
  function_name = var.function_name

  input = <<JSON
{
  "cluster_name": "${var.cluster}",
  "instance_types": "${var.instance_types}"
}
JSON
}

output "result" {
  description = "String result of Lambda execution"
  value = "${data.aws_lambda_invocation.bootstrap.result}"
}
