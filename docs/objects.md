# Objects

**Persistent entities** in the Kubernetes system representing the 
state of the cluster.

* Specifically objects describe:
  - Running containerized applications on all nodes.
  - Available resources and operational policies of an applications
* “record of intent” - once an object is created, Kubernetes ensure its exists.
* Create, modify, or delete objects using the **Kubernetes API**.

The Kubernetes API is accessible with:

* The `kubectl` command-line interface
* Using the REST API via a command line (`curl`, `wget`) or a web UI
* Using a client programming library

## Object Fields

An object includes two nested **object fields**:

* The object **spec** describes the desired state for the object 
* The object **status** describes the actual state of the object

Typically an object is describe with a YAML `.yaml` file including following
required filed:

Field           | Description
----------------|---------------------------------
`apiVersion`    | version of the Kubernetes API
`kind`          | kind of object (i.e. Deployment)
`metadata`      | including a **name** string, **UID**, and optional **namespace**
`spec`          | contains nested fields specific to a resource

The `spec` format is described in the Kubernetes API Reference:

https://kubernetes.io/docs/reference/using-api/api-overview  
https://kubernetes.io/docs/reference/#api-reference

`kubectl explain <object>` describes the fields associated with each supported API
resource.

```bash
# list supported resources
kubectl api-resources
# list all possible fields and subfields
kubectl explain node --recursive
# get details on fields
kubectl explain node.metadata
```

Fields are identified via a simple JSON path identifier `<type>.<fieldName>[.<fieldName>]`.

## Manage Objects

Several ways to apply an objects into the cluster with `kubectl`:

https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview

**Object should be managed using only one technique**

### Imperative

Imperative commands (operates directly on live objects in a cluster):

```bash
# run an instance of the nginx container by creating a deployment object
kubectl create deployment nginx --image nginx
# prints basic information about matching objects
kubectl get deployment nginx
kubectl get deployment nginx -o yaml
kubectl get deployment nginx --show-labels
# aggregated detailed information about matching objects
kubectl describe deployment nginx
# list pods for a given label
kubectl get pods --output wide --selector=app=nginx
# delete an object from a cluster with delete <type>/<name>
kubectl delete deployment/nginx
```

Imperative object configuration with a file contains a definition of the object 
in YAML or JSON format:

```bash
# create the objects defined in a configuration file
kubectl create -f <file>
# delete the objects defined in a coniguration file
kubectl delete -f <file>
# update the objects defined in a configuration file
# note: dropping all changes to the object missing from the configuration file
kubectl replace -f <file>
```

### Declarative

Operates on object configuration files:

* Create, update, and delete operations are automatically detected per-object
* Retains changes made by other writers, even if the changes are not merged 
  back to the object configuration file

```bash
# see what changes are going to be made
kubectl diff -f configs/
# apply changes
kubectl apply -f configs/
```

Use option `-R` for recursive directory decent.
