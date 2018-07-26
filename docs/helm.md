# Helm

[Helm][01] is a package manager for Kubernetes, [source code][02] is hosted on GitHub.

Download and install a [binary release][03] from Github:

```bash
vm ex $K8S_ADMIN_NODE -r '
        cd tmp
        source=https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
        curl -L $source | tar xzv --strip-components=1
        mv helm /usr/bin/
'
```

Architecture/components:

* **Helm** - Command-line client for chart development and interaction with the Tiller server
* **Tiller** - In-cluster server that interfaces with the Kubernetes API server
* **Charts** - Kubernetes packages used to create a Kubernetes application

```bash
# login as admin
vm lo $K8S_ADMIN_NODE
# setup a service account for Tiller services
kubectl --namespace kube-system create serviceaccount tiller
# give the service account full permission to the cluster
kubectl create clusterrolebinding tiller \
        --clusterrole cluster-admin \
        --serviceaccount=kube-system:tiller
# initialize helm and install tiller
helm init --service-account tiller
# get the latest list of charts
helm repo update

```

List of [stable charts][05] on GitHub.

Install Grafana using a helm chart:

```bash
# list all available charts
>>> helm search
# search a specific chart, i.e. Grafana
>>> helm search grafana
NAME          	CHART VERSION	APP VERSION	DESCRIPTION
stable/grafana	1.12.0       	5.1.3      	The leading tool for querying and visualizing t...
# install Grafana
>>> helm install --name grafana stable/grafana
>>> helm list
NAME   	REVISION	UPDATED                 	STATUS  	CHART         	NAMESPACE
grafana	1       	Thu Jul 26 11:43:23 2018	DEPLOYED	grafana-1.12.0	default 
# get the admin user password
>>> kubectl get secret \
        --namespace default grafana \
        --output=jsonpath={.data.admin-password} \
        | base64 --decode ; echo
# get the name of the Grafana pod
>>> grafana_pod_name=$( \
        kubectl get pods \
                --namespace default \
                 --selector=app=grafana \
                 --output=jsonpath={.items..metadata.name} \
    ) && echo $grafana_pod_name
# configure port forwarding
>>> kubectl --namespace default port-forward $grafana_pod_name 3000
```




[01]: https://helm.sh "home page"
[02]: https://github.com/helm/helm "source code repository"
[03]: https://github.com/helm/helm/releases "binary releases"
[04]: https://zero-to-jupyterhub.readthedocs.io/en/latest/setup-jupyterhub.html#setup-jupyterhub "JupyterHub on Kubernetes"
[05]: https://github.com/helm/charts/tree/master/stable "stable charts on GitHub"