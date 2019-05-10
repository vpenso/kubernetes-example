Storage Type          | Lifetime
----------------------|-------------------------
container file-system | container lifetime
volume                | pod lifetime
persistent volume     | cluster lifetime

Kubernetes supports several types of Volumes:

https://kubernetes.io/docs/concepts/storage/volumes/

* The Pod specifies what volumes to provide in `.spec.volumes`
* Containers mount those with `.spec.containers.volumeMounts`

### Empty Directory

An `emptyDir` volume is first created when a Pod is assigned to a Node, 
and exists as long as that Pod is running on that node.

```yaml
spec:
  volumes:
    - name: opt
      emptyDir: {}
  containers:
    - ...
      volumeMounts:
        - name: opt
          mountPath: /opt
```


Create a Pod with two containers using `/opt` to exchange data:

```bash
>>> kubectl create -f shared-volume-example.yaml
>>> kubectl get pod shared-volume-example
NAME                    READY   STATUS    RESTARTS   AGE
shared-volume-example   2/2     Running   0          7s
# write a file into the mounted volume from the first container
>>> kubectl exec shared-volume-example -c debian-container1 cp /etc/hostname /opt
# read the file from the second container
>>> kubectl exec shared-volume-example -c debian-container2 cat /opt/hostname
volume-example
>>> kubectl delete pod shared-volume-example
```

### NFS

Install on all nodes...

```bash
vn exec -r -- yum install -y nfs-utils
```

Deploy an NFS server and mount its export into two containers

```bash
>>> kubectl create -f nfs-server.yaml 
service/nfs-service created
pod/nfs-server created
>>> kubectl exec nfs-server cat /etc/exports
#NFS Exports
/exports *(rw,sync,no_subtree_check,fsid=0,no_root_squash)
>>> kubectl get service nfs-service
NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)            AGE
nfs-service   ClusterIP   10.96.237.49   <none>        2049/TCP,111/UDP   42s
>>> kubectl create -f nfs-volume-example.yaml
pod/nfs-volume-example created
```


