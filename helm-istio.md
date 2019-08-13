
### install helm
```
curl -L https://git.io/get_helm.sh | bash
```

### install local tiller plugin ( does not run on control plane)
```
helm plugin install https://github.com/rimusz/helm-tiller
```

### Install Istio via helm (tillerless)
```
helm tiller start

curl -L https://git.io/getLatestIstio | sh -
cd istio-1.*

helm install \
--wait \
--name istio-init \
--namespace istio-system \
-- set grafana.enabled=true
install/kubernetes/helm/istio-init

helm tiller stop
```
