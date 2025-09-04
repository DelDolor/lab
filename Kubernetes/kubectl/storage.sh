# create a PersistentVolumeClaim manifest
cat <<EOF > storage.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:             # Access modes
    - ReadWriteOnce         # can be mounted as read-write by a single node
  resources:
    requests:
      storage: 1Gi          # Request 1Gi of storage
EOF 

# apply the manifest to create the PVC
k apply -f storage.yaml

k get PersistentVolumeClaim
k describe PersistentVolumeClaim my-pvc

# add a volume to a deployment manifest
    spec.containers:
        volumeMounts:
          - mountPath: /app/data
            name: mealie-data
    spec.volumes:
      - name: mealie-data #name must match volumeMounts name
        persistentVolumeClaim:
          claimName: mealie-data #name must match the PVC name

# apply the updated deployment manifest
k apply -f deployment.yaml

# verify the PVC is bound and the pod is using it
k get pvc