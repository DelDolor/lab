: <<'END_COMMENT'
- Networkin in pod leve
- each pod get its own IP address
- By default, pods can communicate with each other and with the outside world
- - you can restrict this communication using network policies on pod or namespace level
- containers in a pod can communicate with each other using localhost and the port they are listening on

Expose deployment to internet using service instead of individual pods/containers:
- Create a deployment with a container that listens on a specific port (e.g., 9000)
    - k apply -f deployment.yaml
- Expose the deployment using a service (type: LoadBalancer)
    - k expose deployment <deployment-name> --type=LoadBalancer --port 9000



END_COMMENT

#expose pod port to host by defining port parameter to deployment.yaml file (spec/containers/ports:containerPort: 9000)

# forward trafik to pods port manually and connect using localhost:9000
k port-forward -n <namespace> pods/<podaname> <port>  

# port-forward to service port. This is needed if service is used to expose the deployment and doesn't have a public IP address
k port-forward services/<servicename> <port>

# Check which CNI is used
# connect to host node (rancher desktop rdctl shell bash)
ls /etc/cni/net.d/



