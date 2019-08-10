import json
import boto3
from botocore.vendored import requests

def lambda_handler(event, context):
  response = {
    'Status': 'SUCCESS',
    'PhysicalResourceId': context.log_stream_name,
    'Data': {"Message": "IAM update successful!"},
  }

  client = boto3.client('iam')

  try:
      # Trying to check for presence of required keys in event structure and raise error if not.
      if 'KubectlRoleName' not in event:
        raise ValueError("The key 'KubectlRoleName' is not defined in event")
      if 'CodeBuildServiceRoleArn' not in event:
        raise ValueError("The key 'CodeBuildServiceRoleArn' is not defined in event")
      kubectl_role_name = event['KubectlRoleName']
      build_role_arn = event['CodeBuildServiceRoleArn']
      assume = client.get_role(RoleName = kubectl_role_name)
      assume_doc = assume['Role']['AssumeRolePolicyDocument']
      roles = [ { 'Effect': 'Allow', 'Principal': { 'AWS': build_role_arn }, 'Action': 'sts:AssumeRole' } ]
      for statement in assume_doc['Statement']:
        if 'AWS' in statement['Principal']:
          if statement['Principal']['AWS'].startswith('arn:aws:iam:'):
            roles.append(statement)
      assume_doc['Statement'] = roles
      update_response = client.update_assume_role_policy(RoleName = kubectl_role_name, PolicyDocument = json.dumps(assume_doc))

  except Exception as e:
    print(e)
    response['Status'] = 'FAILED'
    response["Reason"] = e
    response['Data'] = {"Message": "IAM update failed"}

  return response


if __name__ == '__main__':
    lambda_handler('event', 'handler')
