
After a client request (i.e. `kubectl`)

1. Authentication by the API server (who can access?)
2. Authorization by modules (what can be accessed?)
3. Admission control by admission controllers


## Authentication

Available authentication methods:

* HTTP basic authentication (username, password)
* Client certificate authentication
* Token based authentication

Request a client certificate via the Kubernetes API:

```bash
# create a private key
openssl genrsa -out ~/.kube/$USER.key
# create a certificate signing request
openssl req -new -key ~/.kube/$USER.key -out ~/.kube/$USER.csr -subj "/CN=$USER/O=devops"
# create a signing request
echo "apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: $USER
spec:
  groups:
  - system:authenticated
  request: $(cat ~/.kube/$USER.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth" > ~/.kube/$USER.yaml
# request the client certificate
kubectl create -f ~/.kube/$USER.yaml
```

Approve the client certificate:

```bash
# the reqeust is in pending state
>>> kubectl get csr $USER
NAME     AGE   REQUESTOR          CONDITION
vpenso   9s    kubernetes-admin   Pending
# as Kubernetes Admin
>>> kubectl config set-context kubernetes-admin@kubernetes
# approve the certificate signing request
>>> kubectl certificate approve $USER
certificatesigningrequest.certificates.k8s.io/vpenso-csr approved
# clean up
>>> kubectl delete csr $USER
```

Use the approved credential:

```bash
# retrive the client certificate
kubectl get csr $USER -o jsonpath='{.status.certificate}' \
        | base64 --decode > ~/.kube/$USER.crt
kubectl config set-credentials $USER \
        --client-certificate=$HOME/.kube/$USER.crt \
        --client-key=$HOME/.kube/$USER.key
```

## Authorization Modules

* Node Authorization - Grants permissions to kubelets based on the pods they
  are scheduled to run
* ABAC (Attribute-based access control) - Access rights are granted to users
  through the use of policies which combine attributes together
* RBAC (Role-based access control) - Grand access based on the roles of 
  individual users to perform specific task, such as view, create, or modify

Check access:

```bash
kubectl auth can-i create deployments --namespace $name
# user impersonation to determine what action other users can perform
kubectl auth can-i list secrets --namespace $name --as $user
```

## Admission Controllers

# Namespaces

_Kubernetes supports multiple virtual clusters backed by the same physical
cluster. These virtual clusters are called namespaces._

Why namespaces?

* Organize user groups onto isolated virtual clusters 
* Separate workloads (services) into functional, isolated units
* Developments environments (development, testing, production)

Namespaces provide:

* Mechanism to **authorize access** to a subsection of the cluster:
  - Resources (pods, services, replication controllers, etc.)
  - Policies (who can or cannot perform actions)
  - Constraints (limit resource consumption (quota), etc.)
* **Avoids naming collisions**, per namespace view on pods, services, and deployments
* Methods to delegate authority to partitions of the cluster to trusted users

Default namespaces:

Namespace   | Description
------------|-----------------------------------
default     | namespace for objects with no other namespace
kube-system | namespace for objects created by the Kubernetes system
kube-public | readable by all users (without authentication)

```bash
kubectl get namespaces         # view available namespace
kubectl --namespace=$name ...  # setting the namespace for a request
kubectl get pods --all-namespaces
# list pods from the Kubernetes service infrastructure
kubectl get pods --namespace=kube-system
```

A **context** groups access parameters under a convenient name:

```bash
kubectl config view            # show the configuration file
kubectl config get-contexts    # view all available contexts
kubectl config current-context # show active context
```

Create a "private" namespace, and use it by default:

```bash
kubectl create namespace $USER # create a namespace
kubectl config set-context --cluster=kubernetes \
        --user=kubernetes-admin --namespace=$USER $USER
kubectl config use-context $USER
# Revert all changes...
kubectl config set-context kubernetes-admin@kubernetes
kubectl config delete-context $USER
kubectl delete namespace $USER
```


