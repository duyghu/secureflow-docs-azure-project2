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

Do not print secret values during the demo. Show the secret names and latest version timestamps in Azure Portal.

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

Use the ops VM as the jump host:

- Ops VM public IP: `4.223.163.109`
- Ops VM username: `azureuser`
- VMSS username: `azureuser`
- Frontend VMSS private IP: `10.2.2.4`
- Backend VMSS private IP: `10.2.3.4`
- SSH key: `/Users/duyguu16/Desktop/group1-final_key.pem`

First verify the ops VM:

```bash
ssh -i /Users/duyguu16/Desktop/group1-final_key.pem \
  -o StrictHostKeyChecking=no \
  azureuser@4.223.163.109
```

Frontend SSH:

```bash
ssh -i /Users/duyguu16/Desktop/group1-final_key.pem \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand='ssh -i /Users/duyguu16/Desktop/group1-final_key.pem -o StrictHostKeyChecking=no -W %h:%p azureuser@4.223.163.109' \
  azureuser@10.2.2.4
```

Backend SSH:

```bash
ssh -i /Users/duyguu16/Desktop/group1-final_key.pem \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand='ssh -i /Users/duyguu16/Desktop/group1-final_key.pem -o StrictHostKeyChecking=no -W %h:%p azureuser@4.223.163.109' \
  azureuser@10.2.3.4
```

Quick non-interactive checks:

```bash
ssh -i /Users/duyguu16/Desktop/group1-final_key.pem \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand='ssh -i /Users/duyguu16/Desktop/group1-final_key.pem -o StrictHostKeyChecking=no -W %h:%p azureuser@4.223.163.109' \
  azureuser@10.2.2.4 "hostname && ip addr show"
```

```bash
ssh -i /Users/duyguu16/Desktop/group1-final_key.pem \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand='ssh -i /Users/duyguu16/Desktop/group1-final_key.pem -o StrictHostKeyChecking=no -W %h:%p azureuser@4.223.163.109' \
  azureuser@10.2.3.4 "hostname && systemctl status secureflow-api --no-pager"
```

## Demo Talk Track

- "There are no public IPs on the frontend or backend VMSS instances."
- "The only administrative path is through the ops VM jump host."
- "VMSS password authentication is disabled; access requires the SSH key."
- "Secrets are stored in Key Vault with private endpoint access and RBAC."
- "The backend VMSS uses its managed identity to fetch SQL, telemetry, and application secrets from Key Vault at deployment time."
