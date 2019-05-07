# Workloads

Types of workloads supported by Kubernetes:

Type                | Description
--------------------|-----------------------------------
Deployment          | Regularly updated, long running applications
Jobs                | Short running tasks
DaemonSets          | Programs run on every node in the cluster

# Jobs

Short-lived, one-off tasks, running until (successful) termination:

* Things to only do once, such as batch jobs or database migrations
* In contrast to regular continuously executed pods

[Job objects][01] creates/manages pods defined by **job specification**:

* Coordinates running multiple pods in parallel
* Restarts pods until successful termination

List of job specifications:

Spec                    | Description
------------------------|-----------------------------------
[job-onshot.yaml][02]   | Short-lived single task job
[job-parallel.yaml][04] | Multiple jobs in parallel
[cronjob.yaml][03]      | Periodically executed job

### One Shot

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
# alternativly use a job specification
kubectl create -f ~/job-onshot.yaml
# check the job status
kubectl describe job/pi
# get the executing pod
kubectl get pods --selector=job-name=pi
# print the result from the log
kubectl logs $(kubectl get pods --selector=job-name=pi --output=jsonpath={.items..metadata.name})
# remove the jobs
kubectl delete job pi
```

### Cron Job

Run jobs on a time-based schedule for creating periodic and recurring tasks:

```bash
# run a job with a given interval
>>> kubectl run hello \
                --schedule="*/1 * * * *" \
                --restart=OnFailure \
                --image=busybox \
                -- /bin/sh -c "date; echo Hello from the Kubernetes cluster"
cronjob.batch/hello created
# alternativly us a job specification
>>> kubectl create -f ~/cronjob.yaml
# show its status
>>> kubectl get cronjob hello
NAME      SCHEDULE      SUSPEND   ACTIVE    LAST SCHEDULE   AGE
hello     */1 * * * *   False     0         19s             28s
# show the jobs executed by the interval
>>> kubectl get jobs
NAME               DESIRED   SUCCESSFUL   AGE
hello-1532427540   1         1            2m
hello-1532427600   1         1            1m
hello-1532427660   1         1            17s
>>> kubectl delete cronjob hello
cronjob "hello" deleted
```

### Parallel

Run multiple pods in parallel for a job by configuring following attributes in the specification:

Attribute         | Description
------------------|--------------------
.spec.completions | number of pods to complete
.spec.parallelism | number of pods to run in parallel

```bash
# attributes in the spec
>>> grep -e completion -e parallelism ~/job-parallel.yaml
  completions: 6
  parallelism: 2
# start the parallel job
>>> kubectl apply -f ~/job-parallel.yaml
job.batch/wait created
# watch the status of pods created
>>> kubectl get -w pods -l job-name=wait
NAME         READY     STATUS    RESTARTS   AGE
wait-qp5l2   1/1       Running   0          22s
wait-tnx79   1/1       Running   0          22s
wait-tnx79   0/1       Completed   0         26s
wait-qp5l2   0/1       Completed   0         26s
wait-z2zv8   0/1       Pending   0         0s
wait-z2zv8   0/1       Pending   0         1s
wait-z2zv8   0/1       ContainerCreating   0         1s
wait-dvbts   0/1       Pending   0         0s
wait-dvbts   0/1       Pending   0         0s
wait-dvbts   0/1       ContainerCreating   0         0s
wait-dvbts   1/1       Running   0         5s
wait-z2zv8   1/1       Running   0         12s
# clean up
>>> kubectl delete -f ~/job-parallel.yaml 
```



[01]: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/ "kubernetes job controllers"
[02]: ../var/specs/job-onshot.yaml
[03]: ../var/specs/cronjob.yaml
[04]: ../var/specs/job-parallel.yaml
