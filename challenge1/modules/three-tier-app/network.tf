# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  address_space       = var.vnet.ip
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }

}

#Create subnets
resource "azurerm_subnet" "subnet-web" {
  name                 = var.subnet_web.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_web.ip
  service_endpoints    = ["Microsoft.Web"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }

  lifecycle {
    ignore_changes = [
      delegation,
    ]
  }
}

resource "azurerm_subnet" "subnet-backend" {
  name                 = var.subnet_backend.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_backend.ip
  service_endpoints    = ["Microsoft.Web"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }

  lifecycle {
    ignore_changes = [
      delegation,
    ]
  }
}

resource "azurerm_subnet" "subnet-db" {
  name                 = var.subnet_db.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_db.ip
  service_endpoints    = ["Microsoft.Sql"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }

  }

  lifecycle {
    ignore_changes = [
      delegation,
    ]
  }
}

resource "azurerm_network_security_group" "nsg-three-tier-app" {
  name                = "nsg-three-tier-app"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "nsr-allow-https-web" {
  name                        = "web"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.0.1.0/28"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-three-tier-app.name
}

resource "azurerm_network_security_rule" "nsr-allow-https-fe-be" {
  name                        = "backend-https"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "10.0.1.0/28"
  destination_address_prefix  = "10.0.2.0/28"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-three-tier-app.name
}

resource "azurerm_network_security_rule" "nsr-allow-sql-be-db" {
  name                        = "be-to-sql-server"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1443"
  source_address_prefix       = "10.0.2.0/28"
  destination_address_prefix  = "10.0.3.0/28"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg-three-tier-app.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc-web" {
  subnet_id                 = azurerm_subnet.subnet-web.id
  network_security_group_id = azurerm_network_security_group.nsg-three-tier-app.id
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc-backend" {
  subnet_id                 = azurerm_subnet.subnet-backend.id
  network_security_group_id = azurerm_network_security_group.nsg-three-tier-app.id
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc-db" {
  subnet_id                 = azurerm_subnet.subnet-db.id
  network_security_group_id = azurerm_network_security_group.nsg-three-tier-app.id
}