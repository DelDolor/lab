#copy the application-azure.properties file from the dm-web pod to your local machine and unzip it.
DM_WEB_POD=$(kubectl get pods --context az -o json -n dm -l "app=web" | jq -r '.items[0].metadata.name')
kubectl --context az cp dm/${DM_WEB_POD}:/app/app.jar /tmp/app.jar
unzip -p /tmp/app.jar BOOT-INF/classes/application-azure.properties > /labs/scratch/application-azure.properties
