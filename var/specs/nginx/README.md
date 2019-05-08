
## Pod

```bash
# create a pod from a configuration file
>>> kubectl create -f pod.yaml
```

Investigate the pod state, hosting node and pod IP address:

```bash
>>> kubectl get pod nginx-simple --output wide
NAME           READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
nginx-simple   1/1     Running   0          59s   192.168.2.5   lxb002   <none>           <none>
>>> kubectl describe pod nginx-simple | grep -e ^Node: -e ^IP:
Node:               lxb002/10.1.1.16
IP:                 192.168.2.5
>>> kubectl get pod nginx-simple -o yaml | grep IP
  hostIP: 10.1.1.16
  podIP: 192.168.2.5
# send a network package
>>> ping -c 3 192.168.2.5
# query the nginx server
>>> curl http://192.168.2.5
```

Accessing the container:

```bash
# run a command in the container
kubectl exec nginx-simple cat /etc/nginx/nginx.conf
# start an interactive shell in the container
kubectl exec nginx-simple -it -- bash
```

## Deployment

```bash
# deploy the specification
>>> kubectl create -f deployment.yaml
deployment.apps/nginx-deployment created
# pods started for this deployment
>>> kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-6dd86d77d-crms7   1/1     Running   0          4m
nginx-deployment-6dd86d77d-swft5   1/1     Running   0          4m
nginx-deployment-6dd86d77d-wbtl6   1/1     Running   0          4m
# show deployment state
>>> kubectl get deployments
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3         3         3            3           1m
# ... in more detail
>>> kubectl describe deployment nginx-deployment | head -n10
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Tue, 24 Jul 2018 13:00:39 +0200
Labels:                 app=nginx
Annotations:            deployment.kubernetes.io/revision=1
Selector:               app=nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
# clean up
>>> kubectl delete -f deployment.yaml
deployment.apps "nginx-deployment" deleted
```

Scaling a deployment

```bash
# show the number of replicas
>>> kubectl get replicaset
NAME                          DESIRED   CURRENT   READY     AGE
nginx-deployment-67594d6bf6   3         3         3         1h
# increase the number of replicas
>>> kubectl scale --replicas=5 deployment/nginx-deployment
deployment.extensions/nginx-deployment scaled
>>> kubectl get replicaset
NAME                          DESIRED   CURRENT   READY     AGE
nginx-deployment-67594d6bf6   5         5         5         1h
# show the pods and worker machines
>>> kubectl --output wide --selector app=nginx get pods
NAME                                READY     STATUS    RESTARTS   AGE       IP             NODE
nginx-deployment-67594d6bf6-6vln5   1/1       Running   0          1h        192.168.3.10   lxb003
nginx-deployment-67594d6bf6-bkptk   1/1       Running   0          1h        192.168.2.11   lxb002
nginx-deployment-67594d6bf6-ht58h   1/1       Running   0          4m        192.168.4.13   lxb004
nginx-deployment-67594d6bf6-skvz8   1/1       Running   0          4m        192.168.1.9    lxb001
nginx-deployment-67594d6bf6-xj4nz   1/1       Running   0          1h        192.168.4.12   lxb004
```
