# local credential are stored in /home/username/.azconfigvars
cat /home/student/.azconfigvars
    export ARM_TENANT_ID=fd6...85
    export ARM_SUBSCRIPTION_ID=dc...648f

    export ARM_CLIENT_ID=91...60
    export ARM_CLIENT_SECRET=1lR8Q~-oV0...dcVj

    export AZURE_LOCATION=northeurope
    export AZURE_VM_SIZE=Standard_A8_v2

# Login using temp. (sample) credentials
ARM_TENANT_ID=fca...6ba6
ARM_CLIENT_ID=e2...ac6c
ARM_CLIENT_SECRET=nM...EOFamx
az login --service-principal --tenant "${ARM_TENANT_ID}" -u "${ARM_CLIENT_ID}" -p="${ARM_CLIENT_SECRET}"

# List subscriptions
az account list

# Check which subscription is enabled
az account show -o table

# change subscription
az account set --subscription "<subscription-id-or-nimi>"


