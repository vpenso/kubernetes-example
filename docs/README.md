## Overview

Basic Concepts:

- **Master** - Central control point (unified view of the cluster).
  Master nodes control multiple (minion) nodes.
- **Node** - Runs one or more pods delegated by the master.
- **Pod** - Smallest deployable unit (created, scheduled, and managed).
- **Volume** - Location where containers read/write data (from/to a storage back-end)
- **Service** - Endpoint that provides load balancing across a pod replication group.

**Kubernetes objects** used to define the desired state of the system
(basically anything that persists in the system).

- Each object in Kubernetes is given a Name, provided to Kubernetes in the 
  deployment record.
- Names need to be unique within a **namespace**.
- The **Kubernetes UID** is a unique, internal identifier for each object in 
  the system (used to differentiate between clones of the same object).

**Labels** are key-value pairs used to identify and describe objects:

- An object can have many labels (only on of each type)
- A way for users to organize and map the objects in the system
- Typically used to identify a group of Pods to perform an action on all

## Master

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


## Nodes

Run pods, provide the Kubernetes runtime environment:

- `kubelet` - Ensures pods/containers are running and healthy.
- `kube-proxy` - Manages network on the host to perform connection forwarding.

Runs on top of the container runtime (i.e. Docker, containerd)



## Pods

Basic unit of organization in Kubernetes (the atom of scheduling & placement):

* Containers are designed to run only a single process per container 
  (unless the process itself spawns child processes)
* Pods **bind containers together** and manage them as a single unit
* Pods can be single container, typically multiple tightly coupled containers

Pods considered to be **ephemeral** rather than durable entities.

* Everything in a Pod will be deployed together, at the same time and location
* Pods have a managed life-cycle, bound to a node (restart in place)
* Pods have a unique specifications (optimized for the container in the Pod)

### Shared Resources

Containers inside a Pod share certain resources (the same set of Linux namespaces)

Containers of a pod run under the same Network and UTS namespaces

* Share the same hostname and network interfaces and **IP address**
* Run under the **same IPC namespace** (port space)
  - Can communicate through `localhost` (loopback network interface)
  - Containers within a Pod can have port conflicts
* Can also share the same PID namespace (not enabled by default)
* The filesystem of each container is fully isolated from other containers

### Inter-Pod Network

All pods in a Kubernetes cluster reside in a single **flat, shared, 
network-address** space (IPs are clustre-scoped):

* All containers can communicate with all other containers without NAT
* All nodes can communicate with all containers (and vice-versa) without NAT
* The IP that a container sees itself as is the same IP that others see it as

Pods communicate across a flat (NAT-less) network like computers on a LAN, 
regardless of the underlying inter-node network topology. Usually build with
an SDN (Software-Defined Network) layer (aka overlay-network).

## Service

Abstraction to define a set of Pods and a policy to access them:

- Services find their associated group of pods using labels
- Provides an endpoint for load balancing accross the replication group
- Is a config unit for the proxies running on a node
