# Kubernetes Example

List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating system              | <https://centos.org>
Docker     | Container Management          | <https://docker.com>
Kubernetes | container Orchestration       | <https://kubernetes.io/>

This example uses a virtual machine setup with [vm-tools][00]:

```bash
# start new VM instances using `centos7` as source image
vn shadow centos7
# install Docker nad Kubernetes on all VM instances
vn cmd k8s-vm-bootstrap {}
```

Cf. [var/aliases/k8s.sh][01]

## Kubernetes

```bash
# initialize the master
vm exec lxcc01 --root kubeadm init
# devops user becomes admins
vm exec lxcm01 -- \
        mkdir -p $HOME/.kube ; \
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config ; \
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
# setup the pod network
vm exec lxcm01 -- kubectl create -f https://git.io/weave-kube
```

[00]: https://github.com/vpenso/vm-tools
[01]: var/aliases/k8s.sh
