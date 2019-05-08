List of components used in this project:

Component  | Description                   | Cf.
-----------|-------------------------------|-----------------------
CentOS 7   | Operating System              | <https://centos.org>
Docker     | Container Run-time            | <https://docker.com>
Kubernetes | Container Orchestration       | <https://kubernetes.io>
Helm       | Kubernetes package manager    | <https://helm.sh>

# Kubernetes Example

File                     | Description
-------------------------|-----------------
[var/aliases/k8s.sh][01] | Shell functions for Kubernetes

Use the following shell functions:

- [k8s-vm-image()][01] - Kickstart a CentOS VM image with Kubernetes prerequisites from [var/centos/7/kickstart.cfg](var/centos/7/kickstart.cfg)
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

> If you already have a way to configure hosting resources, use kubeadm to
> bring up a cluster with a single command per machine.

https://kubernetes.io/docs/setup/pick-right-solution/#custom-solutions

kubeadm gets a minimum viable cluster up and running, cares only about 
bootstrapping, not about provisioning machines. 

- Supports life-cycle mangement (update, downgrade, monitoring)
- Expected to be used by configuration management systems

https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm

### Master

```bash
# start a VM instance for the admin node
vm shadow $K8S_VM_IMAGE $K8S_ADMIN_NODE
# adjust the VM instance configuration
vm config $K8S_ADMIN_NODE --vcpu 2 --memory 2
# restart the VM instance with the new configuration
vm redefine $K8S_ADMIN_NODE
# initialize Kubernetes
vm exec $K8S_ADMIN_NODE --root -- \
        kubeadm init --pod-network-cidr=192.168.0.0/16
# make the devops user Kubernetes admin
vm exec $K8S_ADMIN_NODE -- '
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
'
```

This example uses the kube-router [kuber] as pod network.

```bash
# setup the pod network
vm exec $K8S_ADMIN_NODE -- \
        kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml
```

### Nodes

Add more VM instances to create a Kubernetes cluster

```bash
# list of VM instances to use
NODES=lxcc0[2-3],lxb00[1-4]
# start all cluster nodes
vn shadow $K8S_VM_IMAGE
```

Connect nodes with the cluster

```bash
# get the join command
vm exec $K8S_ADMIN_NODE --root -- \
        kubeadm token create --print-join-command | tr -s ' '
# execute the join command on all nodes
vn exec -r "kubeadm join 10.1.1.9:6443 --token...."
```

Install the Kubernetes Dashboard [webui] on the master node:

```bash
vm exec $K8S_ADMIN_NODE "
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
        sudo kubectl proxy --address=\$(hostname -i) -p 8001 --accept-hosts='^*$'
"
```

## Usage

Copy object specs from [var/specs](var/specs) to the master node, and login

```
k8s-upload-specs && vm exec $K8S_ADMIN_NODE
```

Basic command line:

```bash
kubectl get nodes               # list cluster nodes
kubectl get events              # list cluster events
kubectl get services            # list service running on the cluster
kubectl get pods                # list pods in the cluster
kubectl get pods --namespace=kube-system
kubectl get pods --all-namespaces
kubectl describe pod <name>     # show details for a given pod
```

[00]: https://github.com/vpenso/vm-tools
[01]: var/aliases/k8s.sh
[03]: https://kubernetes.io/docs/concepts/workloads/pods/pod
[04]: https://kubernetes.io/docs/concepts/architecture/nodes
[08]: https://kubernetes.io/docs/setup/scratch "kubernetes from scratch documentation"
[09]: https://github.com/kelseyhightower/kubernetes-the-hard-way "kubernetes the hard way"

# References

[webui] Web-based Kubernetes user interface  
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

[kuber] Kube-router for Kubernetes networking  
https://github.com/cloudnativelabs/kube-router

[deploy] Kubernetes Deployments  
https://kubernetes.io/docs/concepts/workloads/controllers/deployment
