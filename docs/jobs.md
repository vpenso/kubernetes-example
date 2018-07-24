# Jobs

Short-lived, one-off tasks, running until (successful) termination:

* Things to only do once, such as batch jobs or database migrations
* In contrast to regular continuously executed pods

[Job objects][01] creates/manages pods defined by **job specification**:

* Coordinates running multiple pods in parallel
* Restarts pods until successful termination

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
>>> curl -L https://k8s.io/examples/application/job/cronjob.yaml
```
```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```
```bash
# start the hello cronjob
>>> kubectl create -f https://k8s.io/examples/application/job/cronjob.yaml
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

```bash
>>> cat /tmp/spec.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: wait
spec:
  completions: 6
  parallelism: 2
  template:
    metadata:
      name: wait
    spec:
      containers:
      - name: wait
        image: busybox
        command: ["sleep",  "20"]
      restartPolicy: Never
>>> kubectl apply -f /tmp/spec.yaml

>>> kubectl delete -f /tmp/spec.yaml 
```



[01]: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/ "kubernetes job controllers"
