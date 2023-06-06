# resource group and location
variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure Location"
}

# virtual network and subnet
variable "vnet" {
  type = object({
    ip   = list(string)
    name = string
  })
  description = "Virtual network name"
}

variable "subnet_web" {
  type = object({
    ip   = list(string)
    name = string
  })
  description = "Frontend subnet name."
}

variable "subnet_backend" {
  type = object({
    ip   = list(string)
    name = string
  })
  description = "Backend subnet name."
}

variable "subnet_db" {
  type = object({
    ip   = list(string)
    name = string
  })
  description = "Backend subnet name."
}

# App Service 
variable "app_service_plan_frontend" {
  type = object({
    name     = string
    os_type  = string
    sku_name = string
  })
  description = "App service plan details for frontend app."
}

variable "app_service_plan_backend" {
  type = object({
    name     = string
    os_type  = string
    sku_name = string
  })
  description = "App service plan details for backend app."
}

variable "container_registry_name" {
  type        = string
  description = "Azure Container Registry Name"
}

variable "user_assigned_identity_name_acr_pull" {
  type        = string
  description = "User assigned identity name for Azure container registry image pull"
  default     = "ua-mi-acr-pull"
}

variable "frontend_app_name" {
  type        = string
  description = "Frontend app name."
}

variable "docker_image_frontend_app" {
  type        = string
  description = "docker image frontend app url."
}

variable "docker_image_tag_frontend_app" {
  type        = string
  description = "docker image tag for frontend app."
}

variable "backend_app_name" {
  type        = string
  description = "Backend app name."
}

variable "docker_image_backend_app" {
  type        = string
  description = "docker image backend app url."
}

variable "docker_image_tag_backend_app" {
  type        = string
  description = "docker image tag for backend app."
}

# Key vault
variable "key_vault_name" {
  type        = string
  description = "Key vault name"
}

# APM - Log analytics and application insights
variable "log_analytics_workspace_name" {
  type        = string
  description = "Log analytics workspace name"
}

variable "appinsights_frontend_name" {
  type        = string
  description = "Application insights name for frontend app"
}

variable "appinsights_backend_name" {
  type        = string
  description = "Application insights name for backend app"
}

# Database
variable "kv_secret_key_sql_admin_password" {
  type        = string
  description = "Sql admin password for key vault secret"
}

variable "sql_server_name" {
  type        = string
  description = "Sql server unique name"
}

variable "sql_admin_name" {
  type        = string
  description = "Sql server admin name"
}

variable "sql_aad_admin" {
  type        = map(string)
  description = "Sql server azure active directory admin."
}

variable "database_name" {
  type        = string
  description = "Sql server database name"
}

# tags
variable "tags" {
  type        = map(string)
  description = "Tags of the Azure resources"

}