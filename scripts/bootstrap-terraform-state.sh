#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-group1_final}"
LOCATION="${LOCATION:-swedencentral}"
STORAGE_ACCOUNT="${STORAGE_ACCOUNT:-tfstatesecureflow$RANDOM}"
CONTAINER="${CONTAINER:-tfstate}"

az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

az storage container create \
  --account-name "$STORAGE_ACCOUNT" \
  --name "$CONTAINER" \
  --auth-mode login

echo "TFSTATE_RESOURCE_GROUP=$RESOURCE_GROUP"
echo "TFSTATE_STORAGE_ACCOUNT=$STORAGE_ACCOUNT"
echo "TFSTATE_CONTAINER=$CONTAINER"
