#!bin/bash

# List subscriptions
az account list

# Check which subscription is enabled
az account show -o table

# change subscription
az account set --subscription "<subscription-id-or-nimi>"
