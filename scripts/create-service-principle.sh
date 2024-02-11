#!/bin/bash

# Give Terraform Contributor access to the current subscription

# Retrieve the current Azure subscription ID
subscription_id=$(az account show --query id --output tsv)

# Create a service principal with the Contributor role
sp_info=$(az ad sp create-for-rbac --name "tfm-contributor" --role Contributor --scopes "/subscriptions/$subscription_id")

# Extract the appId, password, and tenant from the service principal information
app_id=$(echo "$sp_info" | jq -r '.appId')
password=$(echo "$sp_info" | jq -r '.password')
tenant_id=$(echo "$sp_info" | jq -r '.tenant')

# Assign additional roles to the service principal
az role assignment create --assignee "$app_id" --role "Role Based Access Control Administrator" --scope /subscriptions/$subscription_id
az role assignment create --assignee "$app_id" --role "Key Vault Certificates Officer" --scope /subscriptions/$subscription_id
az role assignment create --assignee "$app_id" --role "Key Vault Secrets Officer" --scope /subscriptions/$subscription_id

# To find which roles contain specific permissions:
# az role definition list --query "[?contains(permissions[0].actions[], 'Microsoft.Authorization/roleAssignments/write')]" --output  json | less
echo ""
echo "Assigned Roles"
echo ""
az role assignment list --assignee $app_id -o table

# Export the Terraform environment variables
export ARM_SUBSCRIPTION_ID="$subscription_id"
export ARM_CLIENT_ID="$app_id"
export ARM_CLIENT_SECRET="$password"
export ARM_TENANT_ID="$tenant_id"

# Output the environment variables for verification
echo ""
echo "Store the following in a password manager"
echo ""
echo "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID"
echo "ARM_CLIENT_ID=$ARM_CLIENT_ID"
echo "ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET"
echo "ARM_TENANT_ID=$ARM_TENANT_ID"
