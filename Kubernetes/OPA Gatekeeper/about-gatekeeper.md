# OPA Gatekeeper
- apiVersion: templates.gatekeeper.sh/v1
    kind: ConstraintTemplate
- apiVersion: constraints.gatekeeper.sh/v1beta1
    kind: K8sDisallowedRepos

Once a Constraint Template is defined, it can be applied to a set of resource actions by defining one or more associated Constraints. The constraint object uses a custom "kind" which matches the one specified in Constraint Template.

## Policy Library
The Open Policy Agent team publishes the Gatekeeper Policy Library which includes a large number of Constraint Templates, with examples showing how to define the constraints and verify the expected behavior. 
https://open-policy-agent.github.io/gatekeeper-library/website/

## Example
### Install
```
.install-opa-policies.sh
```

### Check violations
```
dm-k8s-login-az

kubectl --context az get constraints

kubectl --context az describe <name-from-previous-output>

# or with jq
kubectl --context az get k8sallowedrepos/dm-approved-repo -o yaml | yq -r '.status'

```

