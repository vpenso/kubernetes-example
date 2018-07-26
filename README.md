# Kubernetes Example

List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating System              | <https://centos.org>
Docker     | Container Run-time          | <https://docker.com>
Kubernetes | Container Orchestration       | <https://kubernetes.io/>

This example uses a virtual machine setup with [vm-tools][00]:

```bash
# start new VM instances using `centos7` as source image
vn shadow centos7
# install Docker nad Kubernetes on all VM instances
vn cmd k8s-vm-bootstrap {}
```

Use the following shell function to work with Kubernetes:

File                     | Description
-------------------------|-----------------
[var/aliases/k8s.sh][01] | Shell functions for Kubernetes

- [k8s-vm-bootstrap()][01] - Install Docker and Kubernetes on a given VM instance
- [k8s-vm-join()][01] - Join a given VM instance with the Kubernetes cluster
- [k8s-upload-specs()][01] - Upload Kubernetes specs from [var/specs](var/specs)

## Deployment

Deployment in a single VM instance, cf. [minikube](docs/minikube.md).

[kubeadm][06] provides a simple CLI to create single master Kubernetes clusters:

```bash
# initialize the master
vm exec $K8S_ADMIN_NODE --root -- \
        kubeadm init --pod-network-cidr=192.168.0.0/16
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
vm exec $K8S_ADMIN_NODE -- 
        kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml
# join all other VM instances with the cluster
NODES=lxcc0[2-3],lxb00[1-4] vn cmd k8s-vm-join {}
```

Alternatives: [kubespray][07], [from scratch][08]

## Usage


**[docs/jobs](docs/jobs.md) describes workloads on Kubernetes in more detail.**

```bash
# upload all specification from this repo to the admin node, and login
>>> k8s-upload-specs && vm exec $K8S_ADMIN_NODE
# deploy the specification
>>> kubectl create -f ~/nginx-deployment.yaml
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
>>> kubectl delete -f ~/nginx-deployment.yaml
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
