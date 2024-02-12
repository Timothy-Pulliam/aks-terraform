<details>
<summary>Table of Contents</summary>

<!-- MarkdownTOC autolink=true -->

- [Install Terraform](#install-terraform)
- [Create the Service Priniciple](#create-the-service-priniciple)
- [Create the Terraform Backend](#create-the-terraform-backend)
- [Running Terraform](#running-terraform)
- [More Info](#more-info)
- [Known Issues](#known-issues)
- [Manifest](#manifest)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

<!-- /MarkdownTOC -->

</details>

# Install Terraform

It is recommended to install terraform through [tfenv](https://github.com/tfutils/tfenv)

```
brew install tfenv
tfenv install latest
tfenv list
```

example output

```
tpulliam@lappy aks-terraform % tfenv list
* 1.7.3 (set by /opt/homebrew/Cellar/tfenv/3.0.0/version)
  1.3.9
  1.3.6
```

Make sure to update the `main.tf` file to use the selected Terraform version

main\.tf

```
terraform {
  # Terraform version
  required_version = ">= 1.7.3"

  ...
```

# Create the Service Priniciple

Source the create service principle script. (You must source it to set environment variables in your current shell)

```
source ./scripts/create-service-principle.sh
```

This creates a service principle with the following assigned Roles at the (currently selected) subscription level

- Contributor (to create resource groups, resources, etc.)
- Role Based Access Control Administrator (to grant the App Gateway read access to key vault certs)
- Key Vault Certificates Officer (to create app gateway certificates)
- Key Vault Secrets Officer (to create pgadmin password)

# Create the Terraform Backend

Edit and run the create backend script

```
./scripts/create-tfm-backend.sh
```

Then modify `main.tf` to use the backend

```
  # Create backend using scripts/create-tfm-backend.sh
  # Then fill out the following variables
  backend "azurerm" {
    resource_group_name  = "rg-tfm-backend"
    storage_account_name = "satfmbackend12345"
    container_name       = "tfmstate"
    key                  = "terraform.tfstate"
    # Storage Account Access Key
    # Do not store in plain text!!! Export to env variable instead!!!
    # export ARM_ACCESS_KEY="my-storage-account-access-key"
    # access_key = ""
  }
```

Optionally, set a terraform workspace

```
tpulliam@lappy aks-terraform % terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
tpulliam@lappy aks-terraform % terraform workspace list
  default
* dev
```

Finally, run `terraform init` to initialize the backend

# Running Terraform

Optionally, enable verbose logging to stdout:

- debug
- info
- warn
- error

```
export TF_LOG=info
terraform plan -var-file=./$(terraform workspace show).tfvars -out tfplan
terraform graph
terraform apply tfplan
```

# More Info

https://learn.microsoft.com/en-us/azure/aks/faq

https://github.com/Azure/AKS/releases

# Known Issues

Sometimes, Azure takes a long time to register new providers. This can cause Terraform to stall out, as it waits for azure to complete the registration.

```
tpulliam@lappy aks-terraform % terraform plan -var-file=./$(terraform workspace show).tfvars -out tfplan
...
│ Original Error: Cannot register providers: Microsoft.AVS. Errors were: waiting for Subscription Provider (Subscription: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
│ Provider Name: "Microsoft.AVS") to be registered: context canceled
...
tpulliam@lappy aks-terraform % az provider register --namespace 'Microsoft.AVS'
Registering is still on-going. You can monitor using 'az provider show -n Microsoft.AVS'
```

You can prevent Terraform from registering providers by adding the following to the providers section

```
provider "azurerm" {
  features { }
  skip_provider_registration = true
}
```

# Manifest

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.7.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | 3.91.0   |

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | 3.91.0  |
| <a name="provider_random"></a> [random](#provider_random)    | 3.6.0   |

## Modules

| Name                                            | Source             | Version |
| ----------------------------------------------- | ------------------ | ------- |
| <a name="module_vnet"></a> [vnet](#module_vnet) | Azure/vnet/azurerm | 4.0.0   |

## Resources

| Name                                                                                                                                                                                                       | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_application_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/application_gateway)                                                                    | resource    |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/key_vault)                                                                                        | resource    |
| [azurerm_key_vault_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/key_vault_certificate)                                                                | resource    |
| [azurerm_key_vault_secret.pgadmin_password](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/key_vault_secret)                                                              | resource    |
| [azurerm_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/postgresql_flexible_server)                                                      | resource    |
| [azurerm_postgresql_flexible_server_configuration.accepted_password_auth_method](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/postgresql_flexible_server_configuration) | resource    |
| [azurerm_postgresql_flexible_server_configuration.password_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/postgresql_flexible_server_configuration)           | resource    |
| [azurerm_private_dns_zone.db](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/private_dns_zone)                                                                            | resource    |
| [azurerm_public_ip.appgw_pip](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/public_ip)                                                                                   | resource    |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/resource_group)                                                                              | resource    |
| [azurerm_role_assignment.keyvault_secret_user](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/role_assignment)                                                            | resource    |
| [azurerm_user_assigned_identity.appgw_mi](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/user_assigned_identity)                                                          | resource    |
| [random_id.key_vault_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                                                              | resource    |
| [random_password.pgadmin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                                                                                | resource    |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/client_config)                                                                          | data source |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/key_vault)                                                                                     | data source |
| [azurerm_key_vault_secret.sslcert](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/key_vault_secret)                                                                    | data source |

## Inputs

| Name                                                                           | Description                                        | Type           | Default                                                                                                   | Required |
| ------------------------------------------------------------------------------ | -------------------------------------------------- | -------------- | --------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_address_space"></a> [address_space](#input_address_space)       | cidr range used by vnet                            | `list(string)` | <pre>[<br> "10.0.0.0/16"<br>]</pre>                                                                       |    no    |
| <a name="input_environment"></a> [environment](#input_environment)             | name of environment (dev,qa,uat,prod,etc.)         | `string`       | `"dev"`                                                                                                   |    no    |
| <a name="input_location"></a> [location](#input_location)                      | Azure region/location to deploy to                 | `string`       | `"east us"`                                                                                               |    no    |
| <a name="input_project"></a> [project](#input_project)                         | name of project associated with the resource group | `string`       | `"myapp"`                                                                                                 |    no    |
| <a name="input_subnet_names"></a> [subnet_names](#input_subnet_names)          | list of subnet names to create in vnet             | `list(string)` | n/a                                                                                                       |   yes    |
| <a name="input_subnet_prefixes"></a> [subnet_prefixes](#input_subnet_prefixes) | list of subnet cidr ranges to create in vnet       | `list(string)` | n/a                                                                                                       |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                  | tags to apply to deployed resources                | `map(string)`  | <pre>{<br> "contact": "",<br> "environment": "dev",<br> "project": "",<br> "terraform": "true"<br>}</pre> |    no    |

## Outputs

No outputs.
