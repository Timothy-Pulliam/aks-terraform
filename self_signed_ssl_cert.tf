# Store the PFX file in Azure Key Vault
resource "azurerm_key_vault_certificate" "this" {
  depends_on = [azurerm_key_vault.this]

  name         = "example-cert"
  key_vault_id = azurerm_key_vault.this.id

  certificate {
    contents = filebase64("example.com.pfx")
    password = ""
  }
}
