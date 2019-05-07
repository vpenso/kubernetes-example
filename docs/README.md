# Kubernetes

Deploy Kubernetes on physical infrastructure requires:

* Service to provision bare-metal nodes (installing the operating system)
* **IPs are clustre-scoped**:
  - All containers can communicate with all other containers without NAT
  - All nodes can communicate with all containers (and vice-versa) without NAT
  - The IP that a container sees itself as is the same IP that others see it as
  - Can be layer 3 routed, or a overlay network (SDN).

Kubernetes Setup - Custom Solutions [3]:

> If you already have a way to configure hosting resources, use kubeadm to
> bring up a cluster with a single command per machine.

kubeadm gets a minimum viable cluster up and running, cares only about 
bootstrapping, not about provisioning machines. 

- Supports life-cycle mangement (updatem downgrade, monitoring)
- Expected to be used by configuration management systems

## Architecture

Basic components (concepts):

- **Master** - Central control point (unified view of the cluster).
  Master nodes control multiple (minion) nodes.
- **Nodes** - Run one or more pods delegated by the master.
- **Pods** - Smallest deployable unit (created, scheduled, and managed).
  Logical collection of containers that belong to an application.
- **Volume** - Location where containers read/write data (from/to a storage back-end)
- **Service** - Endpoint that provides load balancing across a pod replicated group.

Kubernetes **objects** used to define the desired state of the Kubernetes system
(basically anything that persists in the system).

- Each object in Kubernetes is given a Name, provided to Kubernetes in the 
  **deployment record**.
- Names need to be unique within a namespace.
- The Kubernetes **UID** is a unique, internal identifier for each object in 
  the system (used to differentiate between clones of the same object).

**Labels** are key-value pairs used to identify and describe objects:

- An object can have many labels (only on of each type)
- A way for users to organize and map the objects in the system
- Typically used to group Pods to perform an action on all

### Master

Provide the cluster’s control plane:

- Makes global decisions about the cluster (i.e. scheduling)
- Detects & responds to cluster events (i.e. start new pod)

Master components:

- `kube-apiserver` - Front-end for the Kubernetes control plane exposes the 
  Kubernetes API (designed to scale horizontally)
- `etcd` - Highly-available key value store (backing store for all cluster data)
- `kube-scheduler` - Schedules pods to nodes based on resource requirements.
- `kube-controller-manager` - Runs controllers...

Controllers:

- Node Controller - Manages various aspects of nodes. Monitoring the node
  health. (Assigns a CIDR block to the node)
- Replication Controller - Ensure a specified number of Pod “replicas” running
  - Continuously monitors pod state, and starts replicas on demand
  - Allows dynamical scaling of the number of replicas
  - Support the concept of rolling updates

### Nodes

Run pods, provide the Kubernetes runtime environment:

- `kubelet` - Ensures pods/containers are running and healthy.
- `kube-proxy` - Manages network on the host to perform connection forwarding.

Runs on top of the container runtime (i.e. Docker, containerd)

### Pods

Basic unit of organization in Kubernetes (the atom of scheduling & placement):

- Everything in a Pod will be deployed together, at the same time, 
  in the same location (on a worker node selected by a scheduler)
- Can be one container, or multiple tightly coupled containers (and volumes)
- The Pod shares a network namespace to the container(s)
  - Multiple containers within a single Pod share an IP address
  - Containers within a Pod see each other through localhost (for IPC)
- Pods have a managed life-cycle, bound to a node (restart in place)
- Pods have a unique specifications (optimized for the container in the Pod)

Pods considered to be **ephemeral** rather than durable entities 

A replication controller schedules/manages multiple copies of a pod.

### Service

Abstraction to define a set of Pods and a policy to access them:

- Services find their group of pods using labels
- Is a config unit for the proxies running on a node
- Provides an endpoint for load balancing accross the replication group





# Reference

[1] Kubernetes Documentation  
https://kubernetes.io/docs/home/

[2] Awesome Kubernetes   
https://github.com/ramitsurana/awesome-kubernetes

[3] Kubernetes Setup - Custom Solution  
https://kubernetes.io/docs/setup/pick-right-solution/#custom-solutions

[4] Kubeadm, GitHub  
https://github.com/kubernetes/kubeadm

[5] Installing Kubeadm  
https://kubernetes.io/docs/setup/independent/install-kubeadm/

[6] Deep Dive: Cluster Lifecycle SIG (kubeadm)  
https://www.youtube.com/watch?v=tAA0Hlag2n0
