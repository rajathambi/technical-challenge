output "instrumentation_key" {
  value     = azurerm_application_insights.appinsights-frontend.instrumentation_key
  sensitive = true
}

output "appinsights_id" {
  value     = azurerm_application_insights.appinsights-frontend.id
  sensitive = true
}

output "frontend_url" {

  value = "${azurerm_linux_web_app.lwa-frontend.name}.azurewebsites.net"
}

output "backedn_url" {

  value = "${azurerm_linux_web_app.lwa-backend.name}.azurewebsites.net"
}