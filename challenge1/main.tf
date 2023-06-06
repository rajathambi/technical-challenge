module "three-tier-app" {

  # import the module
  source = "./modules/three-tier-app"

  # input values
  resource_group_name = "rg-t-three-tier-app"
  location            = "East US"

  vnet = {
    name = "vnet-t-three-tier-app"
    ip   = ["10.0.0.0/16"]
  }

  subnet_web = {
    name = "subnet-web"
    ip   = ["10.0.1.0/28"]
  }

  subnet_backend = {
    name = "subnet-web"
    ip   = ["10.0.1.0/28"]
  }

  subnet_db = {
    name = "subnet-db"
    ip   = ["10.0.3.0/28"]
  }

  app_service_plan_frontend = {
    name     = "asp-frontend"
    os_type  = "Linux"
    sku_name = "B1"
  }

  app_service_plan_backend = {
    name     = "asp-frontend"
    os_type  = "Linux"
    sku_name = "B1"
  }

  container_registry_name = "acrt3tierapp"

  user_assigned_identity_name_acr_pull = "ua-mi-acr-pull"

  frontend_app_name             = "frontend-t-rkt"
  docker_image_frontend_app     = "acrt3tierapp.acr.io/frontend"
  docker_image_tag_frontend_app = "1.0.0"
  backend_app_name              = "backend-t-rkt"
  docker_image_backend_app      = "acrt3tierapp.acr.io/backend"
  docker_image_tag_backend_app  = "1.0.0"

  key_vault_name = "kv-t-three-tier-app"

  log_analytics_workspace_name = "law-t-three-tier-app"
  appinsights_frontend_name    = "appinsights-t-frontend"
  appinsights_backend_name     = "appinsights-t-backend"

  kv_secret_key_sql_admin_password = "sqladminpassword"
  sql_server_name                  = "sql-server-t-three-tier-app"
  sql_admin_name                   = "sqladmin"
  sql_aad_admin = {
    login_username = "azure_ad_sql_server_admin"
    object_id      = "86f50fc0-0d0d-4c26-941d-17dd64ed03a6"
  }

  database_name = "t_three_tier_app"

  tags = {
    Environment  = "DevTest"
    Service_Name = "Three tier app"
  }
}
