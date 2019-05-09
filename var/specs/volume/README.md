
# Volumes

Storage Type          | Lifetime
----------------------|-------------------------
container file-system | container lifetime
volume                | pod lifetime
persistent volume     | cluster lifetime


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

Kubernetes supports several types of Volumes:

https://kubernetes.io/docs/concepts/storage/volumes/

* The Pod specifies what volumes to provide in `.spec.volumes`
* Containers mount those with `.spec.containers.volumeMounts`

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

An `emptyDir` volume is first created when a Pod is assigned to a Node, 
and exists as long as that Pod is running on that node.
