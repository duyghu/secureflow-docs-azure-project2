# SecureFlow Docs Runbook

## Provision

1. Create a remote state storage account and container.
2. Copy `infra/terraform/terraform.tfvars.example` to a local `terraform.tfvars`.
3. Run:

```bash
cd infra/terraform
terraform init \
  -backend-config="resource_group_name=group1_final" \
  -backend-config="storage_account_name=tfstategrp1sf26640" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=secureflow-dev.tfstate"
terraform plan -out=tfplan
terraform apply tfplan
```

## Configure

Install Ansible collections and apply roles from the ops VM `group1-final` (`10.2.0.4`), which can reach the private VMSS instances.

```bash
ansible-galaxy collection install -r config/ansible/requirements.yml
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook config/ansible/site.yml \
  -i config/ansible/inventories/prod/hosts.ini \
  --private-key ~/.ssh/group1-final_key.pem
```

## Deploy

Frontend and backend are independent deployables:

```bash
cd apps/frontend
npm ci
npm run build
tar -czf dist.tar.gz -C dist .

cd ../backend
mvn -B clean verify
```

GitHub Actions automates this through `.github/workflows/frontend.yml` and `.github/workflows/backend.yml`.

## Validate

```bash
curl -k https://135.116.238.100/
```

Expected proof:

- Homepage loads only through the Application Gateway IP or domain.
- App Gateway public IP is `135.116.238.100`.
- Frontend VMSS private IP is `10.2.2.4`.
- Backend VMSS private IP is `10.2.3.4`.
- `POST /api/documents` creates a row in the database.
- `GET /api/documents` returns the new row.
- VMs have no public IP resources attached.
- SQL server has `public_network_access_enabled = false`.
- SQL resolves through `privatelink.database.windows.net`.
- App Gateway backend health shows frontend and backend as healthy.

## Kusto Queries

Application Gateway access:

```kusto
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayAccessLog"
| project TimeGenerated, clientIP_s, requestUri_s, httpStatus_d
| order by TimeGenerated desc
```

WAF blocks:

```kusto
AzureDiagnostics
| where Category == "ApplicationGatewayFirewallLog"
| summarize Blocks=count() by ruleId_s, Message
| order by Blocks desc
```

API failures:

```kusto
requests
| where cloud_RoleName contains "secureflow"
| summarize failures=countif(success == false), total=count() by bin(timestamp, 5m)
```

## Demo Script

- Show `docs/architecture-diagram.svg` and explain one public entry through App Gateway WAF.
- Open the gateway URL and load the SecureFlow Docs homepage.
- Click upload demo document or run the validation script to prove API write and read.
- Show Azure SQL public network access disabled and the private endpoint in `snet-data`.
- Show VM networking with no public IPs and NSGs allowing only App Gateway subnet ingress.
- Show Application Insights, Log Analytics, and the three metric alerts.
- Show Cost Management budget/anomaly controls and the saved cost view from `docs/cost-monitoring-dashboard.md`.
- Show Compliance Mode at `93%` with CIS-style Azure Policy checks and Security Center recommendations from `docs/compliance-mode.md`.
- Show Backup and DR with Azure Backup, SQL PITR, and the restore drill from `docs/backup-disaster-recovery.md`.
- Show AI Security Summary with WAF/API anomaly detection and failed-login burst analysis from `docs/ai-powered-log-analysis.md`.
- Show Key Vault secret storage and VMSS SSH access through the ops VM from `docs/key-vault-and-vmss-access.md`.
- Show the self-hosted GitHub runner `secureflow-ops-runner` on the ops VM and the Terraform-managed Azure Bastion Developer host.
- Show GitHub Actions workflows for infrastructure and independent app deploys.

## Verified Result

- Terraform created the WAF v2 Application Gateway, VMSS tiers, SQL private endpoint, Log Analytics, Application Insights, autoscale settings, and alerts in `group1_final`.
- Ansible completed with zero failures against frontend, backend, and the ops-hosted SonarQube service.
- Public gateway checks from the ops VM returned 200 for `/` and `/api/health`.
- Authenticated gateway test uploaded `secureflow-test-contract.txt` and read it back from `/api/documents` for `duyghu@company.com`.

## Cost Monitoring

Terraform creates:

- `budget-secureflow-dev-monthly`: `$20` monthly budget scoped to `group1_final`.
- 50% and 80% actual-cost alerts.
- 100% forecasted-cost alert.
- `cost-anomaly-sf-dev`: Cost Management anomaly email alert.
- `cost-view-secureflow-dev-daily`: saved Cost Management view for month-to-date daily cost by resource type.

Use [cost-monitoring-dashboard.md](cost-monitoring-dashboard.md) for the professor demo steps and CLI validation commands.

## Compliance Mode

Terraform creates:

- `initiative-secureflow-dev-cis-foundation`: custom CIS-style Azure Policy initiative.
- `pa-secureflow-dev-cis`: resource-group policy assignment for `group1_final`.
- Audit checks for SQL public network access, compute public NIC exposure, and Application Gateway WAF v2.
- Compliance Mode UI score: `93% Compliant`.

Use [compliance-mode.md](compliance-mode.md) for the Azure Policy, CIS benchmark, and Security Center demo steps.

## Backup and Disaster Recovery

Terraform creates:

- `rsv-secureflow-dev-dr`: Recovery Services Vault with soft delete and geo-redundant storage.
- `bkpol-secureflow-dev-vm-daily`: daily VM backup policy.
- SQL short-term retention for `14` day point-in-time restore.
- SQL long-term retention for weekly, monthly, and yearly recovery evidence.
- Azure recovery evidence for Recovery Services Vault, SQL PITR, and restore drill readiness.

Use [backup-disaster-recovery.md](backup-disaster-recovery.md) for the Recovery Services Vault, SQL PITR, and deleted-record restore demo steps.

## AI-Powered Log Analysis

Terraform creates:

- `alert-secureflow-dev-ai-api-traffic-spike`: scheduled Kusto alert for suspicious `/api/*` traffic concentration.
- `alert-secureflow-dev-ai-failed-login-burst`: scheduled Kusto alert for repeated failed login attempts.
- AI Security Summary evidence from Log Analytics alert logic.

Use [ai-powered-log-analysis.md](ai-powered-log-analysis.md) for Kusto queries, alert validation, and the security operations demo script.

## Key Vault and VMSS Access

Terraform creates:

- A private Azure Key Vault with RBAC authorization.
- Key Vault private endpoint in `snet-data`.
- Private DNS zone `privatelink.vaultcore.azure.net`.
- Key Vault secret access for frontend and backend VMSS managed identities.

VMSS SSH access uses the ops VM as a jump host:

```bash
ssh -i /Users/duyguu16/Desktop/group1-final_key.pem \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand='ssh -i /Users/duyguu16/Desktop/group1-final_key.pem -o StrictHostKeyChecking=no -W %h:%p azureuser@4.223.163.109' \
  azureuser@10.2.2.4
```

Use [key-vault-and-vmss-access.md](key-vault-and-vmss-access.md) for secret names and full SSH commands.
