# Kubernetes Example

List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
Docker     | Container Management          | <https://docker.com>
Kubernetes | container Orchestration       | <https://kubernetes.io/>

File                     | Description
-------------------------|-----------------
[var/aliases/k8s.sh][01] | Shell functions for Kubernetes

Use the following shell function to install & configure Kubernetes:

- [k8s-vm-bootstrap()][01] - Install Docker and Kubernetes on a given VM instance
- [k8s-vm-join()][01] - Join a given VM instance with the Kubernetes cluster

This example uses a virtual machine setup with [vm-tools][00]:

```bash
# start new VM instances using `centos7` as source image
vn shadow centos7
# install Docker nad Kubernetes on all VM instances
vn cmd k8s-vm-bootstrap {}
```

## Deployment

[kubeadm][06] provides a simple CLI to create single master Kubernetes clusters:

```bash
# initialize the master
vm exec $K8S_ADMIN_NODE --root -- kubeadm init \
        --pod-network-cidr=192.168.0.0/16
```

This example uses the [kube-router][02] as pod network.

```bash
# devops user becomes admins
vm exec $K8S_ADMIN_NODE -- '
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
'
# setup the pod network
vm exec $K8S_ADMIN_NODE -- kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml
# join all other VM instances with the cluster
NODES=lxcc0[2-3],lxb00[1-4] vn cmd k8s-vm-join {}
```

Alternative: [minikube][docs/minikube.md], [from scratch][08], [kubespray][07]

## Usage

Overview of the cluster:

* [Nodes][04] - Worker machine running pods managed by the master components 
  (services: docker (container run-time), kubelet, kube-proxy)
* Kubelet - Implements the pod/node API and interfaces with the container run-time
* Kube-proxy - Manages virtual IPs for pods using `iptables` 
* [Pod][03] - Group of logically related containers sharing resources

```bash
kubectl cluster-info                 # addresses of the master and services
kubectl get nodes [-o wide]          # list all nodes
kubectl get node <name>              # view single node
kubectl describe node <name>         # view node details
kubectl get services                 # list all services
kubectl get namespaces               # list namespaces
kubectl get pods                         # all pods
```

**Controllers** manage (multiple) pods, replication and rollout (self-healing capabilities at cluster scope):

Create a [deployment][05]:

```bash
# example deployment specification
spec=https://k8s.io/examples/controllers/nginx-deployment.yaml
kubectl create -f $spec              # create a deployment from a specification
kubectl get deployments              # list all deployments
kubectl describe deployments         # view deployment details
```

[00]: https://github.com/vpenso/vm-tools
[01]: var/aliases/k8s.sh
[02]: https://github.com/cloudnativelabs/kube-router/blob/master/docs/kubeadm.md
[03]: https://kubernetes.io/docs/concepts/workloads/pods/pod
[04]: https://kubernetes.io/docs/concepts/architecture/nodes
[05]: https://kubernetes.io/docs/concepts/workloads/controllers/deployment
[06]: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm "kubeadm documentation"
[07]: https://github.com/kubernetes-incubator/kubespray "kubespray on github"
[08]: https://kubernetes.io/docs/setup/scratch "kubernetes from scratch documentation"
[09]: https://github.com/kelseyhightower/kubernetes-the-hard-way "kubernetes the hard way"
