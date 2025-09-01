# https://github.com/falcosecurity/falco
# Falco is a runtime security tool for Linux, containers, and Kubernetes. It monitors system calls in real time, applies rule-based detection to identify abnormal or suspicious behavior, and generates alerts that can be sent to SIEMs or other systems.

# Requirements:
# Enhance AWS EKS cluster to install and configure the Falco sidecar to monitor the dm namespace.
# Connect to the DM container and run a command that triggers a Falco alert.
# Verify the Falco alert is sent to the OTel Collector on the flight simulator by searching for the event in Grafana.

# Part 1 - how to install falco as a sidecar in EKS k8 cluster to monitor selected namespace
kubectl create namespace falco --dry-run=client -o yaml > manifests/falco-ns.yml

helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

helm upgrade -i falco falcosecurity/falco \
  -n falco \
  -f falco-values.yaml

## This can be used if you updated falco-values.yaml
helm upgrade -i falco falcosecurity/falco -n falco -f falco-values.yaml

# part 2 - trigger alert
kubectl run evil --image=httpd -n=dm
kubectl exec -it evil -- /bin/bash
# cat /etc/shadow

# Part 3 - Check findings from Grafana
hostname: ip-10-xxx-199.eu-west-1.compute.internal
output: 18:39:37.476948636: Warning Sensitive file opened for reading by non-trusted program | file=/etc/shadow gparent=containerd-shim ggparent=systemd gggparent=<NA> evt_type=openat user=root user_uid=0 user_loginuid=-1 process=cat proc_exepath=/usr/bin/cat parent=bash command=cat /etc/shadow terminal=34816 container_id=19492c69c205 container_name=attacker container_image_repository=docker.io/library/httpd container_image_tag=latest k8s_pod_name=attacker k8s_ns_name=dm