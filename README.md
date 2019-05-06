# Kubernetes Example

File                     | Description
-------------------------|-----------------
[var/aliases/k8s.sh][01] | Shell functions for Kubernetes

Use the following shell functions:

- [k8s-vm-image()][01] - Kickstart a CentOS VM image with Kubernetes prerequisites from [var/centos/7/kickstart.cfg](var/centos/7/kickstart.cfg)
- [k8s-vm-bootstrap()][01] - Install Docker and Kubernetes on a given VM instance
- [k8s-vm-join()][01] - Join a given VM instance with the Kubernetes cluster
- [k8s-upload-specs()][01] - Upload Kubernetes specs from [var/specs](var/specs)

The shell script ↴ [source_me.sh](source_me.sh) adds the tool-chain in this 
repository to your shell environment:

```bash
source source_me.sh
```

This example uses a virtual machine setup with [vm-tools][00]:

```bash
# Kickstart a CentOS VM image and apply a basic configuration
k8s-vm-image
# list the VM image directory
ls -1 $VM_IMAGE_PATH/$K8S_VM_IMAGE
```

## Deployment

List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating System              | <https://centos.org>
Docker     | Container Run-time            | <https://docker.com>
Kubernetes | Container Orchestration       | <https://kubernetes.io>
Helm       | Kubernetes package manager    | <https://helm.sh>

Deployment in a single VM instance, cf. [minikube](docs/minikube.md).

[kubeadm][06] provides a simple CLI to create single master Kubernetes clusters:

```bash
# VM instance for the admin node
vm shadow $K8S_VM_IMAGE $K8S_ADMIN_NODE
# adjust the VM instance configuration
vm config $K8S_ADMIN_NODE --vcpu 2 --memory 2
vm redefine $K8S_ADMIN_NODE
# initialize the Kubernetes master
vm exec $K8S_ADMIN_NODE --root -- \
        kubeadm init --pod-network-cidr=192.168.0.0/16
# make the devops user Kubernetes admin
vm exec $K8S_ADMIN_NODE -- '
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
'
```

This example uses the [kube-router][02] as pod network.

```bash
# setup the pod network
vm exec $K8S_ADMIN_NODE -- \
        kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml
```

```bash
# join all other VM instances with the cluster
NODES=lxcc0[2-3],lxb00[1-4]
# start the rest of the cluster nodes
vn shadow $K8S_VM_IMAGE
# connect nodes with the cluster
vn cmd k8s-vm-join {}
```

Alternatives: [kubespray][07], [Gravity][12], [from scratch][08], [Rnacher RKE][13]

```bash

kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl get deployment,service --namespace=kube-system kubernetes-dashboard
sudo kubectl proxy --address="$(hostname -i)" -p 443 --accept-hosts='^*$'
```

## Usage


Following example uses a [deployment][05] to start three [Nginx][11] instances:

```bash
# upload all specification from this repo to the admin node, and login
>>> k8s-upload-specs && vm exec $K8S_ADMIN_NODE
# deploy the specification
>>> kubectl create -f ~/deployment/nginx.yaml
deployment.apps/nginx-deployment created
# show deployment state
>>> kubectl get deployments
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3         3         3            3           1m
# ... in more detail
>>> kubectl describe deployment nginx-deployment | head -n10
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Tue, 24 Jul 2018 13:00:39 +0200
Labels:                 app=nginx
Annotations:            deployment.kubernetes.io/revision=1
Selector:               app=nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
# clean up
>>> kubectl delete -f ~/deployment/nginx.yaml
deployment.apps "nginx-deployment" deleted
```

Scaling a deployment

```bash
# show the number of replicas
>>> kubectl get replicaset
NAME                          DESIRED   CURRENT   READY     AGE
nginx-deployment-67594d6bf6   3         3         3         1h
# increase the number of replicas
>>> kubectl scale --replicas=5 deployment/nginx-deployment
deployment.extensions/nginx-deployment scaled
>>> kubectl get replicaset
NAME                          DESIRED   CURRENT   READY     AGE
nginx-deployment-67594d6bf6   5         5         5         1h
# show the pods and worker machines
>>> kubectl --output wide --selector app=nginx get pods
NAME                                READY     STATUS    RESTARTS   AGE       IP             NODE
nginx-deployment-67594d6bf6-6vln5   1/1       Running   0          1h        192.168.3.10   lxb003
nginx-deployment-67594d6bf6-bkptk   1/1       Running   0          1h        192.168.2.11   lxb002
nginx-deployment-67594d6bf6-ht58h   1/1       Running   0          4m        192.168.4.13   lxb004
nginx-deployment-67594d6bf6-skvz8   1/1       Running   0          4m        192.168.1.9    lxb001
nginx-deployment-67594d6bf6-xj4nz   1/1       Running   0          1h        192.168.4.12   lxb004
```

Further reading:

Document                       | Description
-------------------------------|-----------------------------------------------
[docs/jobs.md](docs/jobs.md)   | Oneshot-, parallel- and cron-jobs in more detail
[docs/helm.md](docs/helm.md)   | Describes the **Helm** Kubernetes package manager

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
[10]: var/specs/nginx-deployment.yaml
[11]: http://nginx.org/en/docs/
[12]: https://github.com/gravitational/gravity
[13]: https://github.com/rancher/rke
