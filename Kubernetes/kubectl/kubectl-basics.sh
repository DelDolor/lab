# Basics of kubectl 
# kubectl cheatsheat: https://kubernetes.io/docs/reference/kubectl/quick-reference/

## Usefull kubectl commands
    kubectl get namespaces
    kubectl get pods -A
    kubectl get pods -o wide
    kubectl get pod <pod name> -o yaml
    kubectl edit pod <pod name>
    kubectl descripe pods <pod name>
    kubectl delete pod <pod name>
    kubectl cluster-info
    kubectl config view
    kubectl get events
    kubectl get logs <pod name>
    kubectl get services

## View status of your installation
    sudo k8s status

# Run containers
## Start hello-world kontti
    kubectl run hello-world --image=hello-world --restart=Never

## Check kontti
    kubectl get pods

## Check logs
    kubectl logs <podin-name>

## remove pod & container
This removes pod and container within
    kubectl delete pod hello-world

### remove and lod again
    kubectl delete pod hello-world
    kubectl run hello-world --image=hello-world --restart=Never

## Debug container
### check podin tiedot
#Tämä komento antaa yksityiskohtaisempia tietoja podista ja mahdollisista virheistä, kuten resurssirajoituksista tai puuttuvista riippuvuuksista
    
    kubectl describe pod hello-world

### logs
    kubectl get events
    kubectl get logs <podin nimi>

# restart kubernetes
    sudo kubeadm reset
    sudo kubeadm init

    #and then you need to re-create your profile:

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

## Scale pods

    kubectl scale deployment hello-node --replicas=4

## Open ingres ports and allow user to come
    kubectl expose deployment hello-node --type="LoadBalancer" --port=8080
