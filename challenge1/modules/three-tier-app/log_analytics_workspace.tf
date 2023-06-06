# log analytics workspace
resource "azurerm_log_analytics_workspace" "log-analytics-workspace" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# application insights
resource "azurerm_application_insights" "appinsights-frontend" {
  name                = var.appinsights_frontend_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.log-analytics-workspace.id
  application_type    = "web"

  tags = var.tags

  depends_on = [
    azurerm_log_analytics_workspace.log-analytics-workspace
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_application_insights" "appinsights-backend" {
  name                = var.appinsights_backend_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.log-analytics-workspace.id
  application_type    = "web"

  tags = var.tags

  depends_on = [
    azurerm_log_analytics_workspace.log-analytics-workspace
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}