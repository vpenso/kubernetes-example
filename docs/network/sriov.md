## Mellanox SR-IOV Hardware Switching

RDMA and IP networking in a Kubernetes cluster:

* Use a dedicated networking device for each Kubernetes Pod
* SR-IOV provids virtual HCA (vHCA) devices for RDMA
* The SR-IOV CNI plugin provisions vHCAs using SR-IOV VFs

**Single Root I/O Virtualization** (SR-IOV):

* A physical PCIe device present itself multiple times through the PCIe bus
  * Enables multiple virtual instances of the device with separate resources
  * Up to 96 virtual instances called **Virtual Functions** (VFs) per port
  * Each device can have properties (VLAN,IB partition) and QoS 
* Mellanox SR-IOV plugin [3] for the Kubernetes **Container Network Interface** (CNI)
  * Allows to advertise their resources to the kubelet
  * Native hardware access from the Kubernetes Pods to ConnectX adapter cards
  * Bypass of the host’s kernel and operating-system
  * Pods have their own IB device mapped into the namespace

## References

[1] Kubernetes IPoIB/Ethernet RDMA SR-IOV Networking with ConnectX4/ConnectX5, Mellanox  
https://community.mellanox.com/s/article/kubernetes-ipoib-ethernet-rdma-sr-iov-networking-with-connectx4-connectx5

[2] HowTo Configure SR-IOV for Connect-IB/ConnectX-4 with KVM (InfiniBand), Mellanox  
https://community.mellanox.com/s/article/howto-configure-sr-iov-for-connect-ib-connectx-4-with-kvm--infiniband-x

[3] Kubernetes CNI RDMA SR-IOV device plugin, Mellanox  
https://github.com/Mellanox/k8s-rdma-sriov-dev-plugin  
https://github.com/Mellanox/sriov-cni (DPDK driver)

[4] Deploying SR-IOV in Kubernetes cluster, Wei-Yu Chen  
https://blog.aweimeow.tw/deploying-sriov-in-kubernetes-cluster/

[5] A Hacker’s Guide to Kubernetes Networking, Yaron Haviv  
https://thenewstack.io/hackers-guide-kubernetes-networking/
