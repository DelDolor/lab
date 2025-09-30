
az vm list-ip-addresses -g <resource-group> n -n <vm-name>
az vm list-ip-addresses -g <resource-group> -n <vm-name> | grep ipAddress

## after login to host
cat /etc/ssh/ssh_config