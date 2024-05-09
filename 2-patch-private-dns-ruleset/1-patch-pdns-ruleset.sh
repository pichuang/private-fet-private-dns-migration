#!/usr/bin/env bash
# https://learn.microsoft.com/en-us/cli/azure/dns-resolver/forwarding-rule?view=azure-cli-latest
# az dns-resolver forwarding-rule create --domain-name
#                                        --forwarding-rule-name
#                                        --resource-group
#                                        --ruleset-name
#                                        --target-dns-servers
#                                        [--forwarding-rule-state {Disabled, Enabled}]
#                                        [--if-match]
#                                        [--if-none-match]
#                                        [--metadata]

# Sample
# az dns-resolver forwarding---rule create \
#     --resource-group rg-pdns-eastus2 \
#     --ruleset-name pdns-ruleset \
#     --forwarding-rule-state Enabled \
#     --forwarding-rule-name "rule-test" \
#     --domain-name "blob.core.windows.net." \
#     --target-dns-servers [{iaddress:"10.0.250.196"},{iaddress:"10.0.250.253"}]

# Load .env file
source .env

# # Divecode
# SUBSCRIPTION_ID="XXX-XXX-XXX-XXX" # Replace ID of aliez-Network-Management
# RESOURCE_GROUP="rg-pdns-eastus2"                       # Replace Resource Group Name
# RULESET_NAME="pdns-ruleset"                            # Replace Rule Set Name

# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
declare -A ruleset=(
    ["rule-internal-aliez-poc"]="internal.aliez-poc.com."
    ["rule-azure-api"]="azure-api.net."
    ["rule-azure-device"]="azure-devices.net."
    ["rule-azure-databricks"]="azuredatabricks.net."
    ["rule-blob-core"]="blob.core.windows.net."
    ["rule-azuresynapse"]="azuresynapse.net."
    ["rule-dev-azuresynapse"]="dev.azuresynapse.net."
    ["rule-dfs-core"]="dfs.core.windows.net."
    ["rule-purview"]="purview.azure.com."
    ["rule-purviewstudio"]="purviewstudio.azure.com."
    ["rule-queue-core"]="queue.core.windows.net."
    ["rule-servicebus"]="servicebus.windows.net."
    ["rule-southeastasia-elastic-cloud"]="southeastasia.azure.elastic-cloud.com."
    ["rule-sql-azuresynapse"]="sql.azuresynapse.net."
    ["rule-agentsvc-azure-automation"]="agentsvc.azure-automation.net."
    ["rule-api-azureml"]="api.azureml.ms."
    ["rule-azurewebsites"]="azurewebsites.net."
    ["rule-datafactory-azure"]="datafactory.azure.net."
    ["rule-file-core"]="file.core.windows.net."
    ["rule-mongo-cosmos"]="mongo.cosmos.azure.com."
    ["rule-monitor-azure"]="monitor.azure.com."
    ["rule-notebooks-azure"]="notebooks.azure.net."
    ["rule-ods-opinsights"]="ods.opinsights.azure.com."
    ["rule-oms-opinsights"]="oms.opinsights.azure.com."
    ["rule-redis-cache"]="redis.cache.windows.net."
    ["rule-table-core"]="table.core.windows.net."
    ["rule-sql-database"]="database.windows.net."
)

for rule_name in "${!ruleset[@]}"; do
    az dns-resolver forwarding-rule create \
        --subscription ${SUBSCRIPTION_ID} \
        --resource-group ${RESOURCE_GROUP} \
        --ruleset-name ${RULESET_NAME} \
        --forwarding-rule-state Enabled \
        --forwarding-rule-name $rule_name \
        --domain-name ${ruleset[$rule_name]} \
        --target-dns-servers [{ip-address:"10.0.250.196"},{ip-address:"10.0.250.36"},{ip-address:"10.0.250.37"}]
done

# Add Rule aliez.com

az dns-resolver forwarding-rule create \
    --subscription ${SUBSCRIPTION_ID} \
    --resource-group ${RESOURCE_GROUP} \
    --ruleset-name ${RULESET_NAME} \
    --forwarding-rule-state Enabled \
    --forwarding-rule-name rule-aliez-com \
    --domain-name aliez.com. \
    --target-dns-servers [{ip-address:"10.1.15.1"},{ip-address:"10.1.15.3"}]

# Add Rule Wildcard

az dns-resolver forwarding-rule create \
    --subscription ${SUBSCRIPTION_ID} \
    --resource-group ${RESOURCE_GROUP} \
    --ruleset-name ${RULESET_NAME} \
    --forwarding-rule-state Enabled \
    --forwarding-rule-name rule-wildcard \
    --domain-name . \
    --target-dns-servers [{ip-address:"10.0.250.196"},{ip-address:"10.0.250.36"},{ip-address:"10.0.250.37"}]