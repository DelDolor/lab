#!bin/bash

#list and change sub if needed
az account list
az account set --subscription "<subscription-id-or-nimi>"

# list all groups in current sub
az group list -o table

