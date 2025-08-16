: <<'END_COMMENT'
- Networkin in pod leve
- each pod get its own IP address
- By default, pods can communicate with each other and with the outside world
- - you can restrict this communication using network policies on pod or namespace level
- containers in a pod can communicate with each other using localhost and the port they are listening on
END_COMMENT

#expose pod port to host by defining port parameter to deployment.yaml file (spec/containers/ports:containerPort: 9000)

# forward trafik to pods port manually and connect using localhost:9000
k port-forward -n <namespace> pods/<podaname> <port>    

# Check which cni is used
# connect to host node (rancher desktop rdctl shell bash)
ls /etc/cni/net.d/



