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

# Replace aliez string to specific prefix
# sed -i -e "s/aliez/${PREFIX_NAME}/g" ./20240114-patch-pdns-ruleset.sh

# # Divecode
# SUBSCRIPTION_ID="XXX-XXX-XXX-XXX" # Replace ID of aliez-Network-Management
# RESOURCE_GROUP="rg-pdns-eastus2"                       # Replace Resource Group Name
# RULESET_NAME="pdns-ruleset"                            # Replace Rule Set Name

# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
declare -A ruleset=(
    # Commercial
    ## AI + Machine Learning
    ### Azure Machine Learning (Microsoft.MachineLearningServices/workspaces)
    ["rule-api-azureml-ms"]="api.azureml.ms."
    ["rule-notebooks-azure-net"]="notebooks.azure.net."
    ["rule-instances-azureml-ms"]="instances.azureml.ms."
    ["rule-aznbcontent-net"]="aznbcontent.net."
    ["rule-niference-ml-azure-com"]="inference.ml.azure.com."
    ### Azure AI services (Microsoft.CognitiveServices/accounts)
    ["rule-cognitiveservices-azure-com"]="cognitiveservices.azure.com."
    ["rule-openai-azure-com"]="openai.azure.com."
    ### Azure Bot Service (Microsoft.BotService/botServices)
    ["rule-directline-botframwork-com"]="directline.botframework.com."
    ### Azure Bot Service (Microsoft.BotService/botServices)
    ["rule-token-botframework-com"]="token.botframework.com."

    ## Analytics
    ### Azure Synapse Analytics (Microsoft.Synapse/workspaces)
    ### Azure Synapse Analytics (Microsoft.Synapse/workspaces)
    ["rule-sql-azuresynapse-net"]="sql.azuresynapse.net."
    ### Azure Synapse Analytics (Microsoft.Synapse/workspaces)
    ["rule-dev-azuresynapse-net"]="dev.azuresynapse.net."
    ### Azure Synapse Studio (Microsoft.Synapse/privateLinkHubs)
    ["rule-azuresynapse-net"]="azuresynapse.net."
    ### Azure Event Hubs (Microsoft.EventHub/namespaces)
    ### Azure Service Bus (Microsoft.ServiceBus/namespaces)
    ["rule-servicebus-windows-net"]="servicebus.windows.net."
    ### Azure Data Factory (Microsoft.DataFactory/factories)
    ["rule-datafactory-azure-net"]="datafactory.azure.net."
    ### Azure Data Factory (Microsoft.DataFactory/factories)
    ["rule-adf-azure-com"]="adf.azure.com."
    ### Azure HDInsight (Microsoft.HDInsight/clusters)
    ["rule-azurehdinsight-net"]="azurehdinsight.net."
    ### Azure Data Explorer (Microsoft.Kusto/Clusters)
    ["rule-southeastasia-kusto-windows-net"]="southeastasia.kusto.windows.net."
    # ["rule-blob-core-windows-net"]="blob.core.windows.net."
    # ["rule-queue-core-windows-net"]="queue.core.windows.net."
    # ["rule-table-core-windows-net"]="table.core.windows.net."
    ### Microsoft Power BI (Microsoft.PowerBI/privateLinkServicesForPowerBI)
    ["rule-analysis-windows-net"]="analysis.windows.net."
    ["rule-pbidedicated-windows-net"]="pbidedicated.windows.net."
    ["rule-tip1-powerquery-microsoft-com"]="tip1.powerquery.microsoft.com."
    ### Azure Databricks (Microsoft.Databricks/workspaces)
    ["rule-azure-databricks-net"]="azuredatabricks.net."

    ## Compute
    ### Azure Batch (Microsoft.Batch/batchAccounts)
    ["rule-southeastasia-batch-core-windows-net"]="southeastasia.batch.core.windows.net."
    ["rule-southeastasia-service-core-windows-net"]="southeastasia.service.core.windows.net."
    ### Azure Virtual Desktop (Microsoft.DesktopVirtualization/workspaces)
    ["rule-wvd-microsoft-com"]="wvd.microsoft.com."

    ## Containers
    ### Azure Kubernetes Service - Kubernetes API (Microsoft.ContainerService/managedClusters)
    ["rule-southeastasia-azmk8s-io"]="southeastasia.azmk8s.io."
    ### Azure Container Registry (Microsoft.ContainerRegistry/registries)
    ["rule-azurecr-io"]="azurecr.io."
    ["rule-southeastasia-data-azurecr-io"]="southeastasia.data.azurecr.io."

    ## Databases
    ### Azure SQL Database (Microsoft.Sql/servers)
    ["rule-database-windows-net"]="database.windows.net."
    ### Azure SQL Managed Instance (Microsoft.Sql/managedInstances)
    #XXX {instanceName}.{dnsPrefix}.database.windows.net
    ### Azure Cosmos DB (Microsoft.DocumentDB/databaseAccounts)
    ["rule-documents-azure-com"]="documents.azure.com."
    ["rule-mongo-cosmos-azure-com"]="mongo.cosmos.azure.com."
    ["rule-cassandra-cosmos-azure-com"]="cassandra.cosmos.azure.com."
    ["rule-gremlin-cosmos-azure-com"]="gremlin.cosmos.azure.com."
    ["rule-table-cosmos-azure-com"]="table.cosmos.azure.com."
    ["rule-analytics-cosmos-azure-com"]="analytics.cosmos.azure.com."
    ### Azure Cosmos DB (Microsoft.DBforPostgreSQL/serverGroupsv2)
    ["rule-postgres-cosmos-azure-com"]="postgres.cosmos.azure.com."
    ### Azure Database for PostgreSQL - Single server (Microsoft.DBforPostgreSQL/servers)
    ["rule-postgres-database-azure-com"]="postgres.database.azure.com."
    ### Azure Database for MySQL - Single Server (Microsoft.DBforMySQL/servers)
    ### Azure Database for MySQL - Flexible Server (Microsoft.DBforMySQL/flexibleServers)
    ["rule-mysql-database-azure-com"]="mysql.database.azure.com."
    ### Azure Database for MariaDB (Microsoft.DBforMariaDB/servers)
    ["rule-mariadb-database-azure-com"]="mariadb.database.azure.com."
    ### Azure Cache for Redis (Microsoft.Cache/Redis)
    ["rule-redis-cache-windows-net"]="redis.cache.windows.net."
    ### Azure Cache for Redis Enterprise (Microsoft.Cache/RedisEnterprise)
    ["rule-redisenterprise-cache-windows-net"]="redisenterprise.cache.windows.net."

    ## Hybrid + multicloud
    ### Azure Arc (Microsoft.HybridCompute/privateLinkScopes)
    ["rule-his-arc-azure-com"]="his.arc.azure.com."
    ["rule-guestconfiguration-azure-com"]="guestconfiguration.azure.com."
    ["rule-dp-kubernetesconfiguration-azure-com"]="dp.kubernetesconfiguration.azure.com."

    ## Integration
    ### Azure Service Bus (Microsoft.ServiceBus/namespaces)
    # ["rule-servicebus-windows-net"]="servicebus.windows.net."
    ### Azure Event Grid (Microsoft.EventGrid/topics)
    ### Azure Event Grid (Microsoft.EventGrid/domains)
    ### Azure Event Grid (Microsoft.EventGrid/namespaces)
    ### Azure Event Grid (Microsoft.EventGrid/partnerNamespaces)
    ["rule-eventgrid-azure-net"]="eventgrid.azure.net."
    ### Azure API Management (Microsoft.ApiManagement/service)
    ["rule-azure-api-net"]="azure-api.net."
    ### Azure Health Data Services (Microsoft.HealthcareApis/workspaces)
    ["rule-workspace-azurehealthcareapis-com"]="workspace.azurehealthcareapis.com."
    ["rule-fhir-azurehealthcareapis-com"]="fhir.azurehealthcareapis.com."
    ["rule-dicom-azurehealthcareapis-com"]="dicom.azurehealthcareapis.com."

    ## Internet of Things (IoT)
    ### Azure IoT Hub (Microsoft.Devices/IotHubs)
    ["rule-azure-devices-net"]="azure-devices.net."
    # ["rule-servicebus-windows-net"]="servicebus.windows.net."
    ### Azure IoT Hub Device Provisioning Service (Microsoft.Devices/ProvisioningServices)
    ["rule-azure-devices-provisioning-net"]="azure-devices-provisioning.net."
    ### Device Update for IoT Hubs (Microsoft.DeviceUpdate/accounts)
    ["rule-api-adu-microsoft-com"]="api.adu.microsoft.com."
    ### Azure IoT Central (Microsoft.IoTCentral/IoTApps)
    ["rule-azureiotcentral-com"]="azureiotcentral.com."
    ### Azure Digital Twins (Microsoft.DigitalTwins/digitalTwinsInstances)
    ["rule-digitaltwins-azure-net"]="digitaltwins.azure.net."

    ## Media
    ### Azure Media Services (Microsoft.Media/mediaservices)
    ["rule-media-azure-net"]="media.azure.net."

    ## Management and Governance
    ### Azure Automation (Microsoft.Automation/automationAccounts)
    ["rule-ea-azure-automation-net"]="sea.azure-automation.net."
    ### Azure Backup (Microsoft.RecoveryServices/vaults)
    ["rule-ea-backup-windowsazure-com"]="sea.backup.windowsazure.com."
    ### Azure Site Recovery (Microsoft.RecoveryServices/vaults)
    ["rule-ea-siterecovery-windowsazure-com"]="sea.siterecovery.windowsazure.com."
    ### Azure Monitor (Microsoft.Insights/privateLinkScopes)
    ["rule-monitor-azure-com"]="monitor.azure.com."
    ["rule-oms-opinsights-azure-com"]="oms.opinsights.azure.com."
    ["rule-ods-opinsights-azure-com"]="ods.opinsights.azure.com."
    ["rule-agentsvc-azure-automation-net"]="agentsvc.azure-automation.net."
    # ["rule-blob-core-windows-net"]="blob.core.windows.net."
    ### Microsoft Purview (Microsoft.Purview/accounts)
    ["rule-purview-azure-com"]="purview.azure.com."
    ["rule-purviewstudio-azure-com"]="purviewstudio.azure.com."
    ### Azure Migrate (Microsoft.Migrate/migrateProjects)
    ### Azure Migrate (Microsoft.Migrate/assessmentProjects)
    ["rule-prod-migration-windowsazure-com"]="prod.migration.windowsazure.com."
    ### Azure Resource Manager (Microsoft.Authorization/resourceManagementPrivateLinks)
    #XXX ["rule-azure-com"]="azure.com."
    ### Azure Managed Grafana (Microsoft.Dashboard/grafana)
    ["rule-grafana-azure-com"]="grafana.azure.com."

    ## Security
    ### Azure Key Vault (Microsoft.KeyVault/vaults)
    ["rule-vault-azure-net"]="vault.azure.net."
    ["rule-vaultcore-azure-net"]="vaultcore.azure.net."
    ### Azure Key Vault (Microsoft.KeyVault/managedHSMs)
    ["rule-managedhsm-azure-net"]="managedhsm.azure.net."
    ### Azure App Configuration (Microsoft.AppConfiguration/configurationStores)
    ["rule-azconfig-io"]="azconfig.io."
    ### Azure Attestation (Microsoft.Attestation/attestationProviders)
    ["rule-attest-azure-net"]="attest.azure.net."

    ## Storage
    ### Storage account (Microsoft.Storage/storageAccounts)
    ["rule-blob-core-windows-net"]="blob.core.windows.net."
    ["rule-queue-core-windows-net"]="queue.core.windows.net."
    ["rule-table-core-windows-net"]="table.core.windows.net."
    ["rule-file-core-windows-net"]="file.core.windows.net."
    ["rule-web-core-windows-net"]="web.core.windows.net."
    ### Azure Data Lake File System Gen2 (Microsoft.Storage/storageAccounts)
    ["rule-dfs-core-windows-net"]="dfs.core.windows.net."
    ### Azure File Sync (Microsoft.StorageSync/storageSyncServices)
    ["rule-afs-azure-net"]="afs.azure.net."
    ### Azure Managed Disks (Microsoft.Compute/diskAccesses)
    #XXX privatelink.blob.core.windows.net

    ## Web
    ### Azure Search (Microsoft.Search/searchServices)
    ["rule-search-windows-net"]="search.windows.net."
    ### Azure Relay (Microsoft.Relay/namespaces)
    # ["rule-servicebus-windows-net"]="servicebus.windows.net."
    ### Azure Web Apps - Azure Function Apps (Microsoft.Web/sites)
    ["rule-azurewebsites-net"]="azurewebsites.net."
    ["rule-scm-azurewebsites-net"]="scm.azurewebsites.net."
    ### SignalR (Microsoft.SignalRService/SignalR)
    ["rule-service-signalr-net"]="service.signalr.net."
    ### Azure Static Web Apps (Microsoft.Web/staticSites)
    ["rule-azurestaticapps-net"]="azurestaticapps.net."
    #XXX {partitionId}.azurestaticapps.net
    ### Azure Event Hubs (Microsoft.EventHub/namespaces)

    #
    # Custom
    #


)

i=1

for rule_name in "${!ruleset[@]}"; do
    echo
    echo "===$i===NAME=== $rule_name"
    echo
    az dns-resolver forwarding-rule create \
        --subscription ${SUBSCRIPTION_ID} \
        --resource-group ${RESOURCE_GROUP} \
        --ruleset-name ${RULESET_NAME} \
        --forwarding-rule-state Enabled \
        --forwarding-rule-name $rule_name \
        --domain-name ${ruleset[$rule_name]} \
        --target-dns-servers [{ip-address:"10.101.240.67"}]
    i=$((i+1))
done

# Add Rule ${PREFIX_NAME}.com
# ["rule-fet-com"]="fet.com."
# ["rule-fet-corp"]="fet.corp."
# ["rule-interna"]="fetenergy.com."
#
# Internal DNS Server:
#

az dns-resolver forwarding-rule create \
    --subscription ${SUBSCRIPTION_ID} \
    --resource-group ${RESOURCE_GROUP} \
    --ruleset-name ${RULESET_NAME} \
    --forwarding-rule-state Enabled \
    --forwarding-rule-name rule-fet-com \
    --domain-name fet.com. \
    --target-dns-servers [{ip-address:"192.168.101.19"},{ip-address:"192.168.101.20"}]

az dns-resolver forwarding-rule create \
    --subscription ${SUBSCRIPTION_ID} \
    --resource-group ${RESOURCE_GROUP} \
    --ruleset-name ${RULESET_NAME} \
    --forwarding-rule-state Enabled \
    --forwarding-rule-name rule-fet-corp \
    --domain-name fet.corp. \
    --target-dns-servers [{ip-address:"10.190.254.1"},{ip-address:"10.190.254.2"}]

az dns-resolver forwarding-rule create \
    --subscription ${SUBSCRIPTION_ID} \
    --resource-group ${RESOURCE_GROUP} \
    --ruleset-name ${RULESET_NAME} \
    --forwarding-rule-state Enabled \
    --forwarding-rule-name rule-fetenergy-com \
    --domain-name fetenergy.com. \
    --target-dns-servers [{ip-address:"10.102.2.175"},{ip-address:"10.102.2.176"}]

# Add Rule Wildcard

# az dns-resolver forwarding-rule create \
#     --subscription ${SUBSCRIPTION_ID} \
#     --resource-group ${RESOURCE_GROUP} \
#     --ruleset-name ${RULESET_NAME} \
#     --forwarding-rule-state Enabled \
#     --forwarding-rule-name rule-wildcard \
#     --domain-name . \
#     --target-dns-servers [{ip-address:"10.0.250.196"},{ip-address:"10.0.250.36"},{ip-address:"10.0.250.37"}]