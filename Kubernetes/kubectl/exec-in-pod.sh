# Samples how to execute commands in a pod using kubectl exec
# -it means interactive terminal, allowing you to run commands inside the pod.
#!/bin/bash

kubectl exec -it <pod-name> -- /bin/bash

# or if you want to run a specific command, for example, to check the contents of a file:
kubectl exec -it <pod-name> -- cat /path/to/file

# or to run a command like `ls`:
kubectl exec -it <pod-name> -- ls /path/to/directory

# or to run a command like `env` to check environment variables:
kubectl exec -it <pod-name> -- env