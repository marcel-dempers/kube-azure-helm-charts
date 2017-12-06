#!/bin/bash
azure_service_principal_name=$1
azure_service_principal_key=$2
azure_storage_ad_tenant=$3
azure_storage_subscription=$4 
azure_storage_resource_group=$5
azure_storage_account_name=$6
namespace=$7

echo "subscription: $azure_storage_subscription"
echo "namespace: $namespace"

az login --service-principal -u $azure_service_principal_name -p $azure_service_principal_key --tenant $azure_storage_ad_tenant
az account set --subscription $azure_storage_subscription

az storage account create --name $azure_storage_account_name --resource-group $azure_storage_resource_group --sku Standard_GRS

CONNSTRING=$(az storage account show-connection-string --name $azure_storage_account_name --resource-group $azure_storage_resource_group | jq '.connectionString')

azure_storage_account_key=$(az storage account show-connection-string --name $azure_storage_account_name --resource-group $azure_storage_resource_group | jq '.connectionString' | awk '{print $4}' FS=';' | awk '{print $2}' FS='=')

base64_name=`echo -n "$azure_storage_account_name" | base64`
base64_key=`echo -n "$azure_storage_account_key" | base64 -w 0`

CONFIG=$(az storage account show-connection-string --name $azure_storage_account_name --resource-group $azure_storage_resource_group | base64 | tr -d '\n')
KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)

cat > secret.json <<EOF
{    "apiVersion": "v1",    "data": {
       "azure-storage-secret.json": "$CONFIG",
       "azurestorageaccountname" : "$base64_name",
       "azurestorageaccountkey" : "$base64_key"
    },
    "kind": "Secret",
    "metadata": {
        "name": "storage-connection",
        "namespace": "$namespace"
    },
    "type": "Opaque"
}
EOF

wget -S --header=Content-Type:application/json --no-check-certificate --ca-certificate /var/run/secrets/kubernetes.io/serviceaccount/ca.crt --header "Authorization: Bearer $KUBE_TOKEN" --post-file secret.json "https://kubernetes.default:443/api/v1/namespaces/$namespace/secrets"

