
### install helm
```
curl -L https://git.io/get_helm.sh | bash
```

### install local tiller plugin (does not run on control plane)
```
helm plugin install https://github.com/rimusz/helm-tiller
```

### Install Istio via helm (tillerless)
```
helm tiller start

curl -L https://git.io/getLatestIstio | sh -
cd istio-1.*

helm install install/kubernetes/helm/istio-init \
  --wait \
  --name istio-init \
  --namespace istio-system


helm install install/kubernetes/helm/istio \
    --name istio \
    --namespace istio-system \
    --set grafana.enabled=true


helm tiller stop
```

### Enabled istio injection on the default namespace
```
kubectl label namespace default istio-injection=enabled --overwrite
```

### Make sure istio pods are running
```
kubectl -n istio-system get po
```
