# Kubernetes

### Requirements

Install PKI certificates on all nodes.

**IPs are clustre-scoped**:

- All containers can communicate with all other containers without NAT
- All nodes can communicate with all containers (and vice-versa) without NAT
- The IP that a container sees itself as is the same IP that others see it as

Can be layer 3 routed, or a overlay network (SDN).

## Architecture

Basic components (concepts):

- Master - Central control point (unified view of the cluster).
  Master nodes control multiple minions.
- Nodes - Run one or more pods delegated by the master.
  Application-specific “virtual host” in a containerized environment.
- Pods - Smallest deployable unit (created, scheduled, and managed).
  Logical collection of containers that belong to an application.
- Volume - Location where containers read/write data (from/to a storage back-end)
- Service - Endpoint that provides load balancing across a pod replicated group.
- Label - Key/value pair used for service discovery by the replication
  controller.

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

Runnable unit of work, scheduled to worker nodes (the atom of scheduling &
placement):

- Can be one container, or multiple **tightly coupled containers** & volumes
- **Shared network namespace** (communicate via localhost, share IPC)
- Considered to be **ephemeral** rather than durable entities 
- Managed life-cycle, bound to a node (restart in place)
- A replication controller schedules/manages multiple copies of a pod

### Service

Abstraction to define a set of Pods and a policy to access them:

- Services find their group of pods using labels
- Is a config unit for the proxies running on a node
- Provides an endpoint for load balancing accross the replication group

# Reference

Kubernetes Documentation  
https://kubernetes.io/docs/home/

Awesome Kubernetes   
https://github.com/ramitsurana/awesome-kubernetes
