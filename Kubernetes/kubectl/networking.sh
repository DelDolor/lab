#expose pod port to host by defining port parameter to deployment.yaml file:
# spec/containers/ports:containerPort: 9000

# forward ingress to local port
k port-forward pods/<podaname> <port>
# and connect localhost:9000



