#!/bin/bash

# This script creates an Azure Storage Account
# to store the Terraform backend. This is where
# Terraform stores its state file.

RESOURCE_GROUP_NAME="rg-tfm-backend"
# Note: Storage Account names must be globally unique to Azure
STORAGE_ACCOUNT_NAME="satfmbackend${RANDOM}"
LOCATION="eastus"

# Create Resource Group
az group create --location $LOCATION --name $RESOURCE_GROUP_NAME --tags project=iac

# Create Storage Account
# Note: Storage Account names must be globally unique to Azure
az storage account create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --access-tier hot \
    --allow-blob-public-access false \
    --encryption-services blob \
    --location $LOCATION \
    --sku STANDARD_ZRS \
    --kind StorageV2 

# enable blob container versioning
az storage account blob-service-properties update \
    --enable-versioning true \
    --resource-group $RESOURCE_GROUP_NAME \
    --account-name $STORAGE_ACCOUNT_NAME

# enable container level delete retention (soft delete)
az storage account blob-service-properties update \
    --enable-container-delete-retention true \
    --container-delete-retention-days 7 \
    --account-name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP_NAME

# create blob container
STORAGE_ACCOUNT_ACCESS_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --query "[0].value")
az storage container create \
    --name tfmstate \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_ACCOUNT_ACCESS_KEY