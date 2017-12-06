# Helm chart \ Azure Storage \ on Kubernetes
Helm charts for building Azure storage via Kubernetes 

## Use Case

* a Pod needs storage on Azure
* Someone needs to manually provision storage on Azure
* Someone needs to manually create a Kubernetes secret for the pod to get the storage details.

## What it does

This Helm chart automates the above use case, removing manual efforts!

* Automatically creates a secret in K8 used to access Azure subscription
* Kicks off a Kubernetes job with Azure CLI container and provisions a storage account
* Reads the connection string for the new storage and uses K8 api to inject it as a K8 secret
* The pod that needs the secret will be able to mount it in!

Now your microservices that require storage can mount that secret and access storage.
You can bundle this helm chart with your service charts to provision storage automatically when you summon your pods

## Prerequisites

* Kubectl
* Helm CLI
* Running Kubernetes cluster

## Installation

### Make a Helm values file
Make sure you have a running Kubernetes cluster and your `kubectl` is configured to run against it <br/>

You will need some secret `values.yaml` file for this helm chart

Note: Beware of naming limiations on storage accounts!!

```
namespace: default
storage-create:
  azure_service_principal_name: https://XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  azure_service_principal_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=
  azure_storage_ad_tenant: youradtenant.onmicrosoft.com
  azure_storage_subscription: <Azure-Subscription-ID>
  azure_storage_resource_group: <Azure-Resource-Group-Name>
  azure_storage_account_name:  <Azure-Storage-Account-Name>
  azure_storage_account_location: eastus
```

### Install the chart

```
helm install azure-storage -f values.yaml --namespace default
```

Note: If you change the default namespace in the values file you will need to specify it in your `helm install` namespace flag ;)


