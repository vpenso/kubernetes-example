
Use the specifications within this directory:

```bash
kubectl create namespace prometheus
kubectl create -f cluster_role.yaml
kubectl create -f config_map.yaml -n prometheus
kubectl create -f deployment.yaml -n prometheus
kubectl get deployments -n prometheus
kubectl get pods -n prometheus
kubectl create -n prometheus -f service.yaml
```

Access the Prometheus dashboard using any Kubernetes node IP on port 30000.
