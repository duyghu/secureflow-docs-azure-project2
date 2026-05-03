# Key Vault and Private VMSS Access

SecureFlow Docs stores operational secrets in Azure Key Vault and keeps direct VMSS access private.

## Key Vault

Terraform creates:

- Key Vault: `kv-sfdocs-29c28e`
- Private Endpoint: see Terraform output `key_vault_private_endpoint_name`
- Private DNS zone: `privatelink.vaultcore.azure.net`
- RBAC:
  - current Azure admin: `Key Vault Administrator`
  - frontend VMSS managed identity: `Key Vault Secrets User`
  - backend VMSS managed identity: `Key Vault Secrets User`

The vault is configured with:

- RBAC authorization
- public network access disabled
- purge protection enabled
- soft delete retention
- private endpoint access from the project VNet

## Stored Secrets

The operational secret names are:

- `sql-admin-login`
- `sql-admin-password`
- `vmss-admin-username`
- `vmss-admin-private-key-pem`
- `vmss-admin-public-key`
- `secureflow-default-password`
- `appgw-pfx-base64`
- `appgw-pfx-password`
- `application-gateway-url`
- `frontend-vmss-private-ip`
- `backend-vmss-private-ip`

## Managed Identity Secret Fetch

The backend deployment uses the backend VMSS system-assigned managed identity to fetch runtime secrets from Key Vault over the private endpoint. GitHub Actions no longer passes SQL credentials or the Application Insights connection string directly into the backend service.

The Ansible deploy role requests an Azure AD token from the VM metadata endpoint:

```text
http://169.254.169.254/metadata/identity/oauth2/token
```

Then it reads these Key Vault secrets through `https://kv-sfdocs-29c28e.vault.azure.net`:

- `sql-admin-login`
- `sql-admin-password`
- `application-insights-connection-string`
- `secureflow-default-password`

Those values are rendered into `/etc/secureflow-api.env` on the backend VM with `0600` permissions and `no_log: true` in Ansible.

## VMSS SSH Access

The frontend and backend VMSS instances have private IPs only. Password authentication is disabled.
