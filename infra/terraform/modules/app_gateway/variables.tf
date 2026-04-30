variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "app_gateway_subnet_id" { type = string }
variable "ssl_certificate_base64" {
  type      = string
  sensitive = true
}
variable "ssl_certificate_password" {
  type      = string
  sensitive = true
}
variable "tags" { type = map(string) }
