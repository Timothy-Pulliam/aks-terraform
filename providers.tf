terraform {
  # Terraform version
  required_version = ">= 1.7.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }

  # Create backend using scripts/create-tfm-backend.sh
  # Then fill out the following variables
  backend "azurerm" {
    resource_group_name  = "rg-tfm-backend"
    storage_account_name = "satfmbackend26270"
    container_name       = "tfmstate"
    key                  = "terraform.tfstate"
    # Storage Account Access Key
    # Do not store in plain text!!! Export to env variable instead!!!
    # export ARM_ACCESS_KEY="my-storage-account-access-key"
    # access_key = ""
  }
}

provider "azurerm" {
  # Configuration options
  # alias = ""
  # subscription_id = ""
  features {

  }
  # Azure will sometimes hang when trying to register unneeded providers
  skip_provider_registration = true

  # You should load these via environment variables
  #   subscription_id = ""
  #   client_id       = ""
  #   client_secret   = ""
  #   tenant_id       = ""
  #
  # for example:
  # export ARM_SUBSCRIPTION_ID="<subscription_id>"
  # export ARM_CLIENT_ID="<app_id>"
  # export ARM_CLIENT_SECRET="<password>"
  # export ARM_TENANT_ID="<tenant_id>"

}

locals {
  tags = {
    terraform   = true
    environment = "${var.environment}"
    contact     = ""
    project     = "${var.project}"
  }
}

data "azurerm_client_config" "current" {}
