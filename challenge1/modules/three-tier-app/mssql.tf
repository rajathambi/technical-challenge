#Create Random password 
resource "random_password" "randompassword" {
  length           = 12
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create Key Vault Secret
resource "azurerm_key_vault_secret" "sqladminpassword" {
  name         = var.kv_secret_key_sql_admin_password
  value        = random_password.randompassword.result
  key_vault_id = azurerm_key_vault.keyvault.id
  content_type = "text/plain"
  depends_on = [
    azurerm_key_vault.keyvault
  ]
}

#Azure sql database
resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_name
  administrator_login_password = random_password.randompassword.result

  azuread_administrator {
    login_username = var.sql_aad_admin.login_username
    object_id      = var.sql_aad_admin.object_id
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }

}

# add subnet
resource "azurerm_mssql_virtual_network_rule" "db-vnet-rule" {
  name      = "db-vnet-rule"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = azurerm_subnet.subnet-db.id
  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

resource "azurerm_mssql_database" "database" {
  name           = var.database_name
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 2
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false

}