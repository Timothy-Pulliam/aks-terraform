module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.0.0"

  # insert the 3 required variables here
  resource_group_name = azurerm_resource_group.this.name
  vnet_location       = azurerm_resource_group.this.location
  use_for_each        = true
  # optional parameters
  vnet_name       = "vnet-${var.project}-${var.environment}"
  address_space   = var.address_space
  subnet_names    = var.subnet_names
  subnet_prefixes = var.subnet_prefixes
  # private link endpoint is used to internally map to services
  # suck as Key Vault, ACR, Storage Accounts, using private IP

  subnet_delegation = {
    snet-db = {
      "Microsoft.DBforPostgreSQL.flexibleServers" = {
        service_name = "Microsoft.DBforPostgreSQL/flexibleServers"
        service_actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  }

  # VNet Peering
  #   resource_group_name = azurerm_resource_group.this.name
  #   vnet_location       = azurerm_resource_group.this.location
  #   address_space       = var.vnet_cidr
  #   subnet_names        = var.subnet_names
  #   subnet_cidr         = var.subnet_cidr

  tags = local.tags

}
