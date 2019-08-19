## Install and Configure Kube2iam
This can be installed manually without helm but it is much more cumbersome and will require a handfull of different resources. The manual method is detailed in the first reference doc which is listed below in "Ref Docs" section. (which is what this document is heavily based on)

Ref Docs:

> https://www.rhythmictech.com/blog/aws/using-kube2iam-with-eks/

> https://github.com/jtblin/kube2iam

### Helm
> BEWARE!! There are some security concerns with helm 2 which relate to Tiller. (in-cluster server that interacts with the Helm client, and interfaces with the Kubernetes API server.) Tiller runs with root access and can allow unwanted access to resources.

> More Detail:
https://jfrog.com/blog/is-your-helm-2-secure-and-scalable/
https://rimusz.net/tillerless-helm

#### Helm Install
```
curl -L https://git.io/get_helm.sh | bash
```
#### Values.yaml
```
# Define your region. IAM is global, but actually attaching the role to your running pod requires knowing the region that pod runs in.
aws:
  region: "us-east-1"

# Replace the account number and an option role prefix to restrict the roles your pods can assume
extraArgs:
   base-role-arn: arn:aws:iam::012345678910:role/

# These settings are all that is required for EKS (unless you've decided to install Calico, but if you did, you hopefully know what you're doing)
host:
  iptables: true
  interface: eni+

# If your cluster is running RBAC (it is, right?), leave this alone
rbac:
  create: true
```


#### Install kube2iam
```
helm install --name granite-kube2iam -f values.yaml stable/kube2iam

or

scripts/bootstrap.sh <cluster_name> <aws_region>   # will install cluster autoscaler and metrics server

```

#### Pod Role Example
```
apiVersion: v1
kind: Pod
metadata:
  name: aws-cli
  labels:
    name: aws-cli
  annotations:
    iam.amazonaws.com/role: role-arn
    iam.amazonaws.com/external-id: external-id
spec:
  containers:
  - image: fstab/aws-cli
    command:
      - "/home/aws/aws/env/bin/aws"
      - "s3"
      - "ls"
      - "some-bucket"
    name: aws-cli
```


#### Namespace Restrictions
By using the flag --namespace-restrictions you can enable a mode in which the roles that pods can assume is restricted by an annotation on the pod's namespace. This annotation should be in the form of a json array.

To allow the aws-cli pod specified above to run in the default namespace your namespace would look like the following.

```
  apiVersion: v1
  kind: Namespace
  metadata:
    annotations:
      iam.amazonaws.com/allowed-roles: |
        ["role-arn"]
    name: default
```
