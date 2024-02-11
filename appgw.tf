# while Key Vault can accept PEM certificates, these cannot be directly used by Application Gateway, which requires PFX certificates. Therefore, if you have a PEM certificate, you would need to convert it to PFX before it can be used with Application Gateway

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${module.vnet.vnet_name}-beap"
  frontend_port_name             = "${module.vnet.vnet_name}-feport"
  frontend_ip_configuration_name = "${module.vnet.vnet_name}-feip"
  http_setting_name              = "${module.vnet.vnet_name}-be-htst"
  http_listener_name             = "${module.vnet.vnet_name}-lstn-http"
  https_listener_name            = "${module.vnet.vnet_name}-lstn-https"
  request_routing_rule_name      = "${module.vnet.vnet_name}-rqrt"
  redirect_configuration_name    = "${module.vnet.vnet_name}-rdrcfg"
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

data "azurerm_key_vault" "this" {
  name                = azurerm_key_vault.this.name
  resource_group_name = azurerm_resource_group.this.name
}

# grant managed identity permission to read SSL cert from keyvault
# Create Managed Identity so App GW can read from key vault
# Note: This only applies to keyvault access policies, not RBAC.
resource "azurerm_user_assigned_identity" "appgw_mi" {
  depends_on          = [azurerm_key_vault.this]
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "mi-appgw-${var.project}-${var.environment}"
}


resource "azurerm_role_assignment" "keyvault_secret_user" {
  depends_on = [azurerm_key_vault.this]
  # see list of built in role definitions here: https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-migration#access-policies-to-azure-roles-mapping
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.appgw_mi.principal_id
  scope                = "${data.azurerm_key_vault.this.id}/secrets/example-cert"
}

data "azurerm_key_vault_secret" "sslcert" {
  name         = "example-cert"
  key_vault_id = data.azurerm_key_vault.this.id
  depends_on = [
    azurerm_key_vault_certificate.this
  ]
}

resource "azurerm_application_gateway" "this" {

  name                = "appgw-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  # appgw requires user assigned managed identity to read keyvault secrets
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw_mi.id]
  }

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  ssl_certificate {
    name                = "example-cert"
    key_vault_secret_id = data.azurerm_key_vault_secret.sslcert.id
  }

  ssl_profile {
    name = "SSLProfileTLS12ECDSA"
    ssl_policy {
      policy_name = "SSLProfileTLS12ECDSA"
      policy_type = "Custom"
      cipher_suites = ["TLS_RSA_WITH_AES_256_CBC_SHA256"
        , "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        , "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
        , "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA"
        , "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA"
        , "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256"
      , "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384"]
      min_protocol_version = "TLSv1_2"
    }
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = lookup(module.vnet.vnet_subnets_name_id, "snet-appgw")
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "${local.frontend_port_name}-https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
    # Standard_v2 does not support private ip address only. Must have a public IP. Use WAF instead.
    #private_ip_address_allocation = "Dynamic"
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80 # Container listening port
    protocol              = "Http"
    request_timeout       = 300
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  http_listener {
    name                           = local.https_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "${local.frontend_port_name}-https"
    protocol                       = "Https"
    ssl_certificate_name           = "example-cert"
    ssl_profile_name               = "SSLProfileTLS12ECDSA"
  }

  redirect_configuration {
    name                 = "https-redirect"
    redirect_type        = "Permanent"
    target_listener_name = local.https_listener_name
  }

  # necessary to prevent 401 forbidden
  # 
  #   rewrite_rule_set {
  #     name = "x-forwarded-for"
  #     rewrite_rule {
  #       name          = "x-forwarded-for"
  #       rule_sequence = 100

  #       request_header_configuration {
  #         header_name  = "X-Forwarded-For"
  #         header_value = "{var_add_x_forwarded_for_proxy}"
  #       }
  #     }
  #   }

  # associate redirect_configuration and rewrite_rule_set to listeners
  request_routing_rule {
    name               = local.request_routing_rule_name
    rule_type          = "Basic"
    http_listener_name = local.http_listener_name
    priority           = 2000
    # rewrite_rule_set_name       = "x-forwarded-for"
    redirect_configuration_name = "https-redirect"
  }

  request_routing_rule {
    name                       = "https-redirect"
    rule_type                  = "Basic"
    http_listener_name         = local.https_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 2001
    #   rewrite_rule_set_name      = "x-forwarded-for"
  }
}
