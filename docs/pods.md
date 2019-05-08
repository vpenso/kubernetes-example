# Kubernetes Pods

Basic unit of organization in Kubernetes (the atom of scheduling & placement):

* Containers are designed to run only a single process per container 
  (unless the process itself spawns child processes)
* Pods **bind containers together** and manage them as a single unit
* Pods can be single container, typically multiple tightly coupled containers

Pods considered to be **ephemeral** rather than durable entities.

* Everything in a Pod will be deployed together, at the same time and location
* Pods have a managed life-cycle, bound to a node (restart in place)
* Pods have a unique specifications (optimized for the container in the Pod)

## Shared Resources

Containers inside a Pod share certain resources (the same set of Linux namespaces)

Containers of a pod run under the same Network and UTS namespaces

* Share the same hostname and network interfaces and **IP address**
* Run under the **same IPC namespace** (port space)
  - Can communicate through `localhost` (loopback network interface)
  - Containers within a Pod can have port conflicts
* Can also share the same PID namespace (not enabled by default)
* The filesystem of each container is fully isolated from other containers

## Inter-Pod Network

All pods in a Kubernetes cluster reside in a single **flat, shared, 
network-address** space (IPs are clustre-scoped):

* All containers can communicate with all other containers without NAT
* All nodes can communicate with all containers (and vice-versa) without NAT
* The IP that a container sees itself as is the same IP that others see it as

Pods communicate across a flat (NAT-less) network like computers on a LAN, 
regardless of the underlying inter-node network topology. Usually build with
an SDN (Software-Defined Network) layer (aka overlay-network).



