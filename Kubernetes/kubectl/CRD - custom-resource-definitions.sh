# Kubernetes Custom Resource Definitions (CRDs) are a powerful way to extend the Kubernetes API with custom resources. CRDs are used by many Kubernetes extensions to add new resource types to the cluster.
kubectl get customresourcedefinitions
kubectl get customresourcedefinitions | grep something

kubectl get -n <namespace> some.crd.thing.org 
