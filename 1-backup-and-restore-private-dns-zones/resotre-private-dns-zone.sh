#!/bin/bash

# https://learn.microsoft.com/en-us/cli/azure/network/private-dns/zone?view=azure-cli-latest#az-network-private-dns-zone-import

# Load .env file
source .env

az network private-dns zone import \
    --file-name ${FILE_NAME} \
    --subscription ${SUBSCRIPTION_ID} \
    --resource-group ${RESOURCE_GROUP} \
    --name ${PRIVATE_DNS_NAME}
