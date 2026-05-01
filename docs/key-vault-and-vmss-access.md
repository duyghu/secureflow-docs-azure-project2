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
- `appgw-pfx-base64`
- `appgw-pfx-password`
- `application-gateway-url`
- `frontend-vmss-private-ip`
- `backend-vmss-private-ip`

Do not print secret values during the demo. Show the secret names and latest version timestamps in Azure Portal.

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
- "The application tiers use managed identities that can be granted Key Vault secret read access."
