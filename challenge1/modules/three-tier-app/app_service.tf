# App service plan
resource "azurerm_service_plan" "asp-frontend" {
  name                = var.app_service_plan_frontend.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.app_service_plan_frontend.os_type
  sku_name            = var.app_service_plan_frontend.sku_name

  tags = var.tags

  depends_on = [
    azurerm_subnet.subnet-web
  ]

  lifecycle {
    ignore_changes = [tags]
  }

}

resource "azurerm_service_plan" "asp-backend" {
  name                = var.app_service_plan_backend.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.app_service_plan_backend.os_type
  sku_name            = var.app_service_plan_backend.sku_name

  tags = var.tags

  depends_on = [
    azurerm_subnet.subnet-db
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Load the resource group for azure container registry 
data "azurerm_resource_group" "acr" {
  name = var.resource_group_name
}

# Load the azure container registry 
data "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = var.resource_group_name
}

# set user identity for pull the images from container registry
resource "azurerm_user_assigned_identity" "ua-mi-acr-pull" {
  location            = var.location
  name                = var.user_assigned_identity_name_acr_pull
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "role-assignment-acr-pull" {
  scope                = data.azurerm_resource_group.acr.id
  role_definition_name = "acrpull"
  principal_id         = azurerm_user_assigned_identity.ua-mi-acr-pull.principal_id
  depends_on = [
    azurerm_user_assigned_identity.ua-mi-acr-pull
  ]
}

# Linux web app - Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "lwa-frontend" {
  name                = var.frontend_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.asp-frontend.id
  https_only          = true
  site_config {
    minimum_tls_version = "1.2"
    always_on           = true

    application_stack {
      docker_image     = var.docker_image_frontend_app
      docker_image_tag = var.docker_image_tag_frontend_app
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.appinsights-frontend.instrumentation_key
    "APPINSIGHTS_PROFILERFEATURE_VERSION"        = "1.0.0"
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ua-mi-acr-pull.id]
  }

  virtual_network_subnet_id = azurerm_subnet.subnet-web.id

  tags = var.tags

  depends_on = [
    azurerm_service_plan.asp-frontend,
    azurerm_application_insights.appinsights-frontend,
    azurerm_role_assignment.role-assignment-acr-pull
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_linux_web_app" "lwa-backend" {
  name                = var.backend_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.asp-backend.id
  https_only          = true
  site_config {
    minimum_tls_version = "1.2"
    always_on           = true

    ip_restriction {
      virtual_network_subnet_id = azurerm_subnet.subnet-web.id
      priority                  = 100
      name                      = "Enable access only from Frontend application"
    }

    application_stack {
      docker_image     = var.docker_image_backend_app
      docker_image_tag = var.docker_image_tag_backend_app
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.appinsights-backend.instrumentation_key
    "APPINSIGHTS_PROFILERFEATURE_VERSION"        = "1.0.0"
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
  }

  connection_string {
    name  = "Database"
    type  = "SQLAzure"
    value = "Server=tcp:azurerm_mssql_server.sql_server.fully_qualified_domain_name;Database=azurerm_mssql_database.database.name;User ID=azurerm_mssql_server.sql_server.administrator_login;Password=azurerm_mssql_server.sql_server.administrator_login_password;Trusted_Connection=False;Encrypt=True;"
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ua-mi-acr-pull.id]
  }

  tags = var.tags

  depends_on = [
    azurerm_service_plan.asp-backend,
    azurerm_application_insights.appinsights-backend,
    azurerm_role_assignment.role-assignment-acr-pull,
    azurerm_mssql_server.sql_server
  ]

  lifecycle {
    ignore_changes = [tags]
  }

}

# vnet integration for the web apps
resource "azurerm_app_service_virtual_network_swift_connection" "frontend-vnet-integration" {
  app_service_id = azurerm_linux_web_app.lwa-frontend.id
  subnet_id      = azurerm_subnet.subnet-web.id

  depends_on = [
    azurerm_linux_web_app.lwa-frontend
  ]
}

resource "azurerm_app_service_virtual_network_swift_connection" "appservice-vnet-backend-integration" {
  app_service_id = azurerm_linux_web_app.lwa-backend.id
  subnet_id      = azurerm_subnet.subnet-db.id
  depends_on = [
    azurerm_linux_web_app.lwa-backend
  ]
}