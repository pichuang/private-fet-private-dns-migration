#!/usr/bin/env bash

# Place Root Management Group instead of Tenant Root Group
MG_NAME="divecode"

az policy definition create \
    --name "[Policy] Deny Azure Private DNS Zone PrivateLink" \
    --display-name "[Policy] Deny Azure Private DNS Zone PrivateLink" \
    --description "This policy restricts creation of private DNS zones with the .privatelink prefix" \
    --mode All \
    --management-group ${MG_NAME} \
    --rules "{ \"if\": { \"allOf\": [ { \"field\": \"type\", \"equals\": \"Microsoft.Network/privateDnsZones\" }, { \"field\": \"name\", \"contains\": \"privatelink.\" } ] }, \"then\": { \"effect\": \"deny\" } }"

