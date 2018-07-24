# Jobs Patterns on Kubernetes

Short-lived, one-off tasks, running until (successful) termination:

* Things to only do once, such as batch jobs or database migrations
* In contrast to regular continuously executed pods

**Job object** creates/manages pods defined by **job specification**:

* Coordinates running multiple pods in parallel
* Restarts pods until successful termination

```bash
# start an interactive container
kubectl run busybox \
            --stdin \
            --tty \
            --image=busybox \
            --restart=Never
# start a container to execute a perl script
kubectl run pi \
            --image=perl \
            --restart=OnFailure \
            -- perl -Mbignum=bpi -wle 'print bpi(2000)'
# check the job status
kubectl describe job/pi
# get the executing pod
kubectl get pods --selector=job-name=pi
# print the result from the log
kubectl logs $(kubectl get pods --selector=job-name=pi --output=jsonpath={.items..metadata.name})
# remove the jobs
kubectl delete job pi
```

Using a job specification:

```bash
curl -L https://k8s.io/examples/controllers/job.yaml
```
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```
```bash
# run the job spec
kubectl create -f https://k8s.io/examples/controllers/job.yaml
```
