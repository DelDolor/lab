# What?
This verifies that image is Cosign-signed before launching it.

When an image is reviewed for admission, it is checked against all globs for ALL Cluster Image Policy resources. To be admitted to the cluster, at least 1 authority in EACH Policy must return a "pass" result (eg. confirm an image has a valid signature). A Policy in "warn" mode will return a "pass" result and generate a warning message.

If no Cluster Image Policy matches the image, the controller will apply the behavior set by the no-match-policy in the "config-policy-controller" config map-

## Example
There are 2 "ClusterImagePolicy" resources defined in this file, separated by YAML document markers - the --- line
- lab\Tools\cosign\cosign-cluster-image-policy.yaml

### first policy 
resource trust-signed-xxx-images matches image globs for both of XXX's AWS and Azure container registries, and returns a "pass" if the image is signed by a specified key. Images from both clouds will be signed by the same public key authority, so there is a placeholder in the file using the go language's template format ({{ ... }}) to allow the key to be inserted programmatically.

### The second policy 
(trust-csp-cli-images) matches image globs for cloud service provider CLI images, and returns a "pass" action for any image that matches either name.

### 

# kubernets Cosign Admission Control
Cosign Policy Controller is configured using 3 components. First, the admission controller's overall defaults are configured using a ConfigMap named config-policy-controller in the namespace where the controller is installed ("cosign-system" by default). Second, labels applied to namespaces are used to opt in to utilizing the admission controller on each namespace. Finally, instances of the ClusterImagePolicy custom resource definition are used to define policies that apply to sets of images.

## Install using helm 
in warn mode
```
helm upgrade --install policy-controller sigstore/policy-controller --version 0.6.3 \
  --namespace cosign-system --create-namespace --wait --timeout "5m31s" \
  --set-json webhook.configData='{"no-match-policy": "warn"}'
```

## display the cosign policy controller configuration
```
kubectl get -n cosign-system configmap config-policy-controller -o yaml
```

## Check where cosign label is included
kubectl get namespace -l "policy.sigstore.dev/include=true"
