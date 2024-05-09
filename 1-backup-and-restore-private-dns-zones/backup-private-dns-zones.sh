#!/bin/bash

# https://learn.microsoft.com/en-us/cli/azure/network/private-dns?view=azure-cli-latest

# Load .env file
source .env

DIRNAME=backup-private-dns-zones-$(date +%Y%m%d-%H%M%S)
ROOT_DIR=$(pwd)/${DIRNAME}

# List all subriptions withing specific Tenant ID
for SUBSCRIPTION_ID in `az account list -o json --query "[?tenantId=='${TENANT_ID}'].id" | jq -r '.[]'`; do
    echo "## In ${SUBSCRIPTION_ID}"
    #
    # Check the list is not empty
    #
    ZONE_QUERY=$(az network private-dns zone list \
        --subscription ${SUBSCRIPTION_ID} \
        --output json)

    if [ "$ZONE_QUERY" = "[]" ] || [ -z "$ZONE_QUERY" ]; then
        # echo "The list is empty, then break"
        continue
    else
        # echo "The list is not empty, then backup"
        mkdir -p ${ROOT_DIR}/${SUBSCRIPTION_ID};
        echo $ZONE_QUERY | jq . > ${ROOT_DIR}/${SUBSCRIPTION_ID}/${SUBSCRIPTION_ID}-private-dns-zones.json
    fi

    #
    # List all Private DNS Zones in each resource group
    #
    for RESOURCE_GROUP in `cat ${ROOT_DIR}/${SUBSCRIPTION_ID}/${SUBSCRIPTION_ID}-private-dns-zones.json | jq -r '.[].resourceGroup'`; do
        echo "### In ${RESOURCE_GROUP} ${SUBSCRIPTION_ID}"

        #
        # Create a folder for each resource group if not exist
        #
        if [ -d ${ROOT_DIR}/${SUBSCRIPTION_ID}/${RESOURCE_GROUP} ]; then
            continue
        else
            mkdir -p ${ROOT_DIR}/${SUBSCRIPTION_ID}/${RESOURCE_GROUP};
        fi

        #
        # List all Private DNS Zones in each resource group
        #
        for PRIVATE_DNS_ZONE in `cat ${ROOT_DIR}/${SUBSCRIPTION_ID}/${SUBSCRIPTION_ID}-private-dns-zones.json | jq -r '.[].name'`; do
            echo "#### In ${PRIVATE_DNS_ZONE} ${RESOURCE_GROUP} ${SUBSCRIPTION_ID}"

            # echo Backup Private DNS Zone: ${PRIVATE_DNS_ZONE} in resource group: ${RESOURCE_GROUP} in subscription: ${SUBSCRIPTION_ID}
            #
            # Create a folder for each Private DNS Zone if not exist
            #
            mkdir -p ${ROOT_DIR}/${SUBSCRIPTION_ID}/${RESOURCE_GROUP}/${PRIVATE_DNS_ZONE};

            # Backup each Private DNS Zone
            az network private-dns zone export \
                --name ${PRIVATE_DNS_ZONE} \
                --resource-group ${RESOURCE_GROUP} \
                --subscription ${SUBSCRIPTION_ID} \
                --output json > ${ROOT_DIR}/${SUBSCRIPTION_ID}/${RESOURCE_GROUP}/${PRIVATE_DNS_ZONE}/${PRIVATE_DNS_ZONE}.json

        done
    done
done

#
# Tar all files
#

tar -czvf backup-pdns-${DIRNAME}.tar.gz ${DIRNAME}

echo
echo "============================="
echo "Total number of files:" $(find ./${DIRNAME} -type f ! -name '*-private-dns-zones.json' | wc -l)
echo
find ./${DIRNAME} -type f ! -name '*-private-dns-zones.json'
echo "============================="
echo

