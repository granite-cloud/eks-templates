# Assign IAM Roles to EKS Service Accounts
> AKA No More Kubet2iam or Kiam

https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/


### Retrive the OIDC Endpoint from Cluster
```
aws eks describe-cluster --name cluster_name --query cluster.identity.oidc.issuer --output text
```

### Install eksctl
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

# check version
eksctl version
```

### Create OIDC Provider in IAM
> Appears this is not yet available in aws cli api. Hence why the divergence in tools)

```
eksctl utils associate-iam-oidc-provider --name cluster_name --approve
```

#### Create IAM Role/Policy for the Service Account
```
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

OIDC_PROVIDER=$(aws eks describe-cluster --name granite-cloud --query cluster.identity.oidc.issuer --output text | sed -e "s/^https:\/\///")

SERVICE_ACCOUNT_NAMESPACE=kube-system

SERVICE_ACCOUNT_NAME=aws-node
```

##### Role
```
read -r -d '' TRUST_RELATIONSHIP <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$AWS_ACCOUNT_ID:oidc-provider/$OIDC_PROVIDER"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$OIDC_PROVIDER:sub": "system:serviceaccount:$SERVICE_ACCOUNT_NAMESPACE:$SERVICE_ACCOUNT_NAME"
        }
      }
    }
  ]
}
EOF

echo "$TRUST_RELATIONSHIP" > trust.json

aws iam create-role --role-name eks-pod-role --assume-role-policy-document file://trust.json --description "This is a test role for the new eks IAM to service account functionality"

aws iam attach-role-policy --role-name eks-pod-role --policy-arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

#### Assign Service Account to Pods
> Add the service account name to the deployment template spec containers section
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  serviceAccountName: <service account name>
  containers:
  - name: myapp
    image: myapp:1.2

```

> The actual pods will now have the env vars set to the IAM role ARN and mount the OIDC Token
```
<snippet>
spec:
  containers:
  - env:
    - name: AWS_ROLE_ARN
      value: arn:aws:iam::627177891842:role/eks-pod-role
    - name: AWS_WEB_IDENTITY_TOKEN_FILE
      value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token
    image: 627177891842.dkr.ecr.us-east-1.amazonaws.com/granite-cloud:1.2
    imagePullPolicy: Always
    name: hello-k8s
    ports:
    - containerPort: 8080
      protocol: TCP
    resources: {}
    securityContext:
      allowPrivilegeEscalation: false
      privileged: false
      readOnlyRootFilesystem: true
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: aws-node-token-rvpn9
      readOnly: true
    - mountPath: /var/run/secrets/eks.amazonaws.com/serviceaccount
      name: aws-iam-token
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: ip-10-100-4-222.ec2.internal
  priority: 0
```
