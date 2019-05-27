# Networking

**Containers in a pod share the network**:

* Common network namespace, one network interface, a single IP address
* Containers use `localhost` for communication (no external networking)
* Pod to pod communication over OSI layer 3 (routing) managed by **network plugins**

Nodes have an **assigned IP subnet as address pool** for the pods.
```
# show pool IP addresses per node
>>> kubectl get nodes \
            --sort-by=.metadata.name \
            --output=custom-columns=NAME:.metadata.name,IP:.status.addresses[0].address,PODS:.spec.podCIDR
NAME      IP          PODS
lxb001    10.1.1.15   192.168.1.0/24
lxb002    10.1.1.16   192.168.2.0/24
lxb003    10.1.1.17   192.168.3.0/24
lxb004    10.1.1.18   192.168.4.0/24
lxcc01    10.1.1.9    192.168.0.0/24
lxcc02    10.1.1.10   192.168.5.0/24
lxcc03    10.1.1.11   192.168.6.0/24
```
```bash
# create a pod with a simple web-server
>>> kubectl create deployment nginx --image=nginx
# look for the pods IP address
>>> kubectl get pods --output wide --selector=app=nginx
NAME                     READY     STATUS    RESTARTS   AGE       IP            NODE
nginx-78f5d695bd-pkxh9   1/1       Running   0          1m        192.168.4.4   lxb004
# access the web server
>>> curl http://192.168.4.4
...
```

## Pod Network

Investigate the pod network on the node:

```bash
# containers running on the node
>>> docker ps -af name=nginx | tail -n+2 | tr -s ' ' | cut -d' ' -f-2
d9115fe869d3 docker.io/nginx@sha256:d85914d547a6c92faa39ce7058bd7529baacab7e0cd4255442b04577c4d1f424
ad48356baa38 k8s.gcr.io/pause:3.1
# nginx uses the pause-container as gatekeeper
>>> docker inspect d9 ad | grep -e NetworkMode -e Pid\"
            "Pid": 10907,
            "NetworkMode": "container:ad48356baa386524d359d19832a22a70d973825195c3080a63db93705889a637",
            "Pid": 10817,
            "NetworkMode": "none",
# virtual peer interface number
>>> nsenter -t 10907 -n ethtool -S eth0                 
NIC statistics:
     peer_ifindex: 6
# both share a single network namespace
>>> nsenter -t 10907 -n ip link show | grep eth0
3: eth0@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
>>> nsenter -t 10817 -n ip link show | grep eth0
3: eth0@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
nsenter -t 10907 -n ip addr show dev eth0 | head -n3
# verify the assigned IP address
3: eth0@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 0a:58:c0:a8:04:04 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.4.4/24 scope global eth0
```

In this example interface "3" in the pod/container is paired with interface "6" on the node:

* Two **virtual interfaces bonded** together (think like a virtual patch cable)
* The node `veth` interface is **attached to a bridge** (here `kube-bridge`)

```bash
# show the bridge and interface 6
>>> ip l | grep bridge
4: kube-bridge: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
6: vethc92900e3@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master kube-bridge state UP mode DEFAULT group default
# which is paired with interface 3
>>> ethtool -S vethc92900e3      
NIC statistics:
     peer_ifindex: 3
```

## Service Routes

Pods typically use service IPs/ports to communicate with others

```bash
>>> kubectl create service nodeport nginx --tcp=80:80
>>> kubectl get service --selector=app=nginx
NAME      TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx     NodePort   10.99.138.146   <none>        80:32479/TCP   53s
```

Packages leaving a container routed through the host IP (usually masqueraded):

* Connects the host to  the `eth0` in the container network namespace
* `iptables` configures a **route to the container** network namespace

```bash
# inspect the host
>>> iptables-save | grep nginx                       
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/nginx:80-80" -m tcp --dport 32479 -j KUBE-MARK-MASQ
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/nginx:80-80" -m tcp --dport 32479 -j KUBE-SVC-OVTWZ4GROBJZO4C5
-A KUBE-SEP-AIU7VSID7D2D2Z4F -s 192.168.4.4/32 -m comment --comment "default/nginx:80-80" -j KUBE-MARK-MASQ
-A KUBE-SEP-AIU7VSID7D2D2Z4F -p tcp -m comment --comment "default/nginx:80-80" -m tcp -j DNAT --to-destination 192.168.4.4:80
-A KUBE-SERVICES ! -s 192.168.0.0/16 -d 10.99.138.146/32 -p tcp -m comment --comment "default/nginx:80-80 cluster IP" -m tcp --dport 80 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.99.138.146/32 -p tcp -m comment --comment "default/nginx:80-80 cluster IP" -m tcp --dport 80 -j KUBE-SVC-OVTWZ4GROBJZO4C5
-A KUBE-SVC-OVTWZ4GROBJZO4C5 -m comment --comment "default/nginx:80-80" -j KUBE-SEP-AIU7VSID7D2D2Z4F
# netfilter connection tracking
>>> conntrack -L                       
```

Overlay network, allows communication of pods/containers across worker nodes:

* Manages the route table on each worker node



[01]: https://github.com/containernetworking/cni "CNCF repo for CNI"
