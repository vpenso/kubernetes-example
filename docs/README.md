# Kubernetes

Kubernetes Setup - Custom Solutions [setup]:

> If you already have a way to configure hosting resources, use kubeadm to
> bring up a cluster with a single command per machine.

kubeadm gets a minimum viable cluster up and running, cares only about 
bootstrapping, not about provisioning machines. 

- Supports life-cycle mangement (updatem downgrade, monitoring)
- Expected to be used by configuration management systems

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

### Service

Abstraction to define a set of Pods and a policy to access them:

- Services find their associated group of pods using labels
- Provides an endpoint for load balancing accross the replication group
- Is a config unit for the proxies running on a node




# Reference

[docs] Kubernetes Documentation  
https://kubernetes.io/docs/home

[setup] Kubernetes Setup - Custom Solution  
https://kubernetes.io/docs/setup/pick-right-solution/#custom-solutions


