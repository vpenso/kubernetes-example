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

## Kubernetes

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

[00]: https://github.com/vpenso/vm-tools
[01]: var/aliases/k8s.sh
[02]: https://github.com/cloudnativelabs/kube-router/blob/master/docs/kubeadm.md
