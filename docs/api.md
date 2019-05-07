

`kubectl` handles locating and authenticating to the API server

```bash
# check the location and credentials
kubectl config view
```

Accessing the REST API with an http client:

```bash
# kubectl in a mode where it acts as a reverse proxy
kubectl proxy --port=8080 &
# query the API
curl http://localhost:8080/api/
```
