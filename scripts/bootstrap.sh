#!/bin/bash


if [ -z "$1" ]
then
  echo "**************************"
  echo "Usage: `basename $0` <cluster_name>"
  echo "**************************"
  echo "example: ./`basename $0` test-cluster"
  exit 0
fi

# Input
cluster_name=$1
account=$(aws sts get-caller-identity | jq -r  .Account)


###################
# Install the k8s Cluster Autoscaler
###################
install_ca(){
  echo "=> trying to apply the yaml..."
  cat << EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
    labels:
      k8s-addon: cluster-autoscaler.addons.k8s.io
      k8s-app: cluster-autoscaler
    name: cluster-autoscaler
    namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
    name: cluster-autoscaler
    labels:
      k8s-addon: cluster-autoscaler.addons.k8s.io
      k8s-app: cluster-autoscaler
rules:
    - apiGroups: [""]
      resources: ["events", "endpoints"]
      verbs: ["create", "patch"]
    - apiGroups: [""]
      resources: ["pods/eviction"]
      verbs: ["create"]
    - apiGroups: [""]
      resources: ["pods/status"]
      verbs: ["update"]
    - apiGroups: [""]
      resources: ["endpoints"]
      resourceNames: ["cluster-autoscaler"]
      verbs: ["get", "update"]
    - apiGroups: [""]
      resources: ["nodes"]
      verbs: ["watch", "list", "get", "update"]
    - apiGroups: [""]
      resources:
        - "pods"
        - "services"
        - "replicationcontrollers"
        - "persistentvolumeclaims"
        - "persistentvolumes"
      verbs: ["watch", "list", "get"]
    - apiGroups: ["extensions"]
      resources: ["replicasets", "daemonsets"]
      verbs: ["watch", "list", "get"]
    - apiGroups: ["policy"]
      resources: ["poddisruptionbudgets"]
      verbs: ["watch", "list"]
    - apiGroups: ["apps"]
      resources: ["statefulsets", "replicasets", "daemonsets"]
      verbs: ["watch", "list", "get"]
    - apiGroups: ["storage.k8s.io"]
      resources: ["storageclasses"]
      verbs: ["watch", "list", "get"]
    - apiGroups: ["batch", "extensions"]
      resources: ["jobs"]
      verbs: ["get", "list", "watch", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
    name: cluster-autoscaler
    namespace: kube-system
    labels:
      k8s-addon: cluster-autoscaler.addons.k8s.io
      k8s-app: cluster-autoscaler
rules:
    - apiGroups: [""]
      resources: ["configmaps"]
      verbs: ["create","list","watch"]
    - apiGroups: [""]
      resources: ["configmaps"]
      resourceNames: ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
      verbs: ["delete", "get", "update", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
    name: cluster-autoscaler
    labels:
      k8s-addon: cluster-autoscaler.addons.k8s.io
      k8s-app: cluster-autoscaler
roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-autoscaler
subjects:
    - kind: ServiceAccount
      name: cluster-autoscaler
      namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
    name: cluster-autoscaler
    namespace: kube-system
    labels:
      k8s-addon: cluster-autoscaler.addons.k8s.io
      k8s-app: cluster-autoscaler
roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: cluster-autoscaler
subjects:
    - kind: ServiceAccount
      name: cluster-autoscaler
      namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
    name: cluster-autoscaler
    namespace: kube-system
    labels:
      app: cluster-autoscaler
spec:
    replicas: 1
    selector:
      matchLabels:
        app: cluster-autoscaler
    template:
      metadata:
        labels:
          app: cluster-autoscaler
      spec:
        serviceAccountName: cluster-autoscaler
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
              - matchExpressions:
                - key: beta.kubernetes.io/instance-type
                  operator: In
                  values:
                  - t2.small
                  - t3.small
                  - t3.medium
        containers:
          - image: k8s.gcr.io/cluster-autoscaler:v1.12.3
            name: cluster-autoscaler
            resources:
              limits:
                cpu: 100m
                memory: 300Mi
              requests:
                cpu: 100m
                memory: 300Mi
            command:
              - ./cluster-autoscaler
              - --v=4
              - --stderrthreshold=info
              - --cloud-provider=aws
              - --skip-nodes-with-local-storage=false
              - --expander=least-waste
              - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/$cluster_name
              - --balance-similar-node-groups
              - --scale-down-unneeded-time=2m
            volumeMounts:
              - name: ssl-certs
                mountPath: /etc/ssl/certs/ca-certificates.crt
                readOnly: true
            imagePullPolicy: "Always"
        volumes:
          - name: ssl-certs
            hostPath:
              path: "/etc/ssl/certs/ca-bundle.crt"
EOF
}


###########
# https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
#
# Install the k8s metric server required for pod autoscaler
###########
install_metrics_server(){
    echo "Installing metrics server"
    DOWNLOAD_URL=$(curl --silent "https://api.github.com/repos/kubernetes-incubator/metrics-server/releases/latest" | jq -r .tarball_url)
    DOWNLOAD_VERSION=$(grep -o '[^/v]*$' <<< $DOWNLOAD_URL)
    curl -Ls $DOWNLOAD_URL -o /tmp/metrics-server-$DOWNLOAD_VERSION.tar.gz
    mkdir /tmp/metrics-server-$DOWNLOAD_VERSION
    tar -xzf /tmp/metrics-server-$DOWNLOAD_VERSION.tar.gz --directory /tmp/metrics-server-$DOWNLOAD_VERSION --strip-components 1
    kubectl apply -f /tmp/metrics-server-$DOWNLOAD_VERSION/deploy/1.8+/
}

install_kube2iam(){
  # Install tillerless helm V2 plugin
  helm plugin install https://github.com/rimusz/helm-tiller
  helm tiller start
  # Install kube2iam
    cat << EOF | helm install --name granite-kube2iam -f -
---
aws:
region: "us-east-1"
extraArgs:
   base-role-arn: arn:aws:iam::$account:role/
host:
  iptables: true
  interface: eni+
rbac:
  create: true
EOF
  exit
}

aws eks update-kubeconfig --name $cluster_name
install_ca
install_metrics_server
install_kube2iam
