output "application_insights_connection_string" {
  value     = azurerm_application_insights.main.connection_string
  sensitive = true
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "monthly_budget_name" {
  value = azurerm_consumption_budget_resource_group.monthly.name
}

output "cost_anomaly_alert_name" {
  value = azurerm_cost_anomaly_alert.daily.name
}

output "cost_management_view_name" {
  value = azurerm_resource_group_cost_management_view.dashboard.name
}
