output "application_gateway_public_ip" {
  description = "Only public endpoint for SecureFlow Docs."
  value       = module.app_gateway.public_ip_address
}

output "application_gateway_https_url" {
  value = "https://${module.app_gateway.public_ip_address}/"
}

output "frontend_vmss_name" {
  value = module.compute.frontend_vmss_name
}

output "backend_vmss_name" {
  value = module.compute.backend_vmss_name
}

output "sql_private_endpoint_fqdn" {
  value = module.database.sql_private_fqdn
}

output "monthly_budget_name" {
  value = module.monitoring.monthly_budget_name
}

output "cost_anomaly_alert_name" {
  value = module.monitoring.cost_anomaly_alert_name
}

output "cost_management_view_name" {
  value = module.monitoring.cost_management_view_name
}
