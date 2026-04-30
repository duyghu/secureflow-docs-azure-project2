resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.main.id
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "platform" {
  name                = "ag-${var.name_prefix}-platform"
  resource_group_name = var.resource_group_name
  short_name          = "sfdocs"
  tags                = var.tags

  email_receiver {
    name          = "platform-email"
    email_address = var.action_email
  }
}

resource "azurerm_monitor_metric_alert" "app_gateway_unhealthy" {
  name                = "alert-${var.name_prefix}-appgw-unhealthy"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_gateway_id]
  description         = "Application Gateway backend health below 100 percent for 5 minutes."
  frequency           = "PT1M"
  window_size         = "PT5M"
  severity            = 1
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "HealthyHostCount"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 2
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_metric_alert" "frontend_cpu" {
  name                = "alert-${var.name_prefix}-frontend-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.frontend_vm_id]
  description         = "Frontend VMSS CPU above 70 percent for 5 minutes."
  frequency           = "PT1M"
  window_size         = "PT5M"
  severity            = 2
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_metric_alert" "backend_cpu" {
  name                = "alert-${var.name_prefix}-backend-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.backend_vm_id]
  description         = "Backend VMSS CPU above 70 percent for 5 minutes."
  frequency           = "PT1M"
  window_size         = "PT5M"
  severity            = 2
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_metric_alert" "sql_dtu" {
  name                = "alert-${var.name_prefix}-sql-dtu"
  resource_group_name = var.resource_group_name
  scopes              = [var.sql_database_id]
  description         = "Azure SQL DTU consumption above 80 percent for 5 minutes."
  frequency           = "PT1M"
  window_size         = "PT5M"
  severity            = 2
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "app_gateway" {
  name                       = "diag-${var.name_prefix}-appgw"
  target_resource_id         = var.app_gateway_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
