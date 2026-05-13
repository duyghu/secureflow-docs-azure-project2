output "app_gateway_id" { value = data.azurerm_application_gateway.existing.id }
output "public_ip_address" { value = data.azurerm_public_ip.existing_appgw.ip_address }
output "frontend_backend_pool_id" { value = null }
output "api_backend_pool_id" { value = null }
output "waf_policy_id" { value = azurerm_web_application_firewall_policy.main.id }
