resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = var.app_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  backend_address_pool {
    name  = var.backend_address_pool_name
    fqdns = var.backend_fqdns
  }

  backend_http_settings {
    name                           = var.http_setting_name
    cookie_based_affinity          = "Disabled"
    path                           = "/"
    port                           = 443
    protocol                       = "Https"
    request_timeout                = 60
    pick_host_name_from_backend_address = true
    probe_name                     = "appGatewayProbe"
  }

  probe {
    name                                      = "appGatewayProbe"
    protocol                                  = "Https"
    path                                      = "/"
    host                                      = var.backend_fqdns[0]
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    
    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
    priority                   = 100
  }

  tags = var.tags
}
