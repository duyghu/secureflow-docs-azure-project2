# SecureFlow Docs Runbook

## Provision

1. Use the existing Azure resource group `rg-secureflow-project2` and VNet `vnet-secure-app` (`10.0.0.0/16`, West Europe).
2. Terraform remote state is stored in `tfstatesfdocs2duyghu` / `tfstate`.
3. Run Terraform from `infra/terraform`:

```bash
cd infra/terraform
terraform init   -backend-config="resource_group_name=rg-secureflow-project2"   -backend-config="storage_account_name=tfstatesfdocs2duyghu"   -backend-config="container_name=tfstate"   -backend-config="key=secureflow-dev.tfstate"
terraform plan -out=tfplan
terraform apply tfplan
```

## Configure

The private VMSS tiers are configured through Azure VMSS Run Command. This keeps compute private: no public VM IPs, no direct SSH exposure, and no dependency on an internet-facing jump box.

Ansible playbooks remain in `config/ansible/` as the configuration-management evidence for package/service layout, but the active GitHub deployment path uses Azure Run Command because the current resource group does not contain a self-hosted ops runner.

## Deploy

Frontend and backend are independent deployables:

```bash
cd apps/frontend
npm ci
npm run build

cd ../backend
mvn -B clean verify
```

GitHub Actions automates deployment through:

- `.github/workflows/frontend.yml`: builds Vite, uploads the artifact to private storage, then deploys to `vmss-secureflow-dev-frontend` with Azure Run Command.
- `.github/workflows/backend.yml`: builds Spring Boot, uploads the JAR to private storage, then deploys to `vmss-secureflow-dev-backend` with Azure Run Command.
- `.github/workflows/infra.yml`: runs Terraform init, validate, plan, and optional apply.
- `.github/workflows/threat-intel.yml`: refreshes WAF malicious IP rules from a threat feed.
- `.github/workflows/dast.yml`: runs OWASP ZAP baseline scanning against the public gateway URL.

## Validate

```bash
curl -k --resolve e-document.tech:443:20.105.178.184 https://e-document.tech/
curl -k --resolve e-document.tech:443:20.105.178.184 https://e-document.tech/api/health
```

Expected proof:

- Homepage loads only through Application Gateway / WAF.
- App Gateway public IP is `20.105.178.184`.
- Frontend internal load balancer private IP is `10.0.12.10`.
- Backend internal load balancer private IP is `10.0.13.10`.
- `/` routes to frontend; `/api/*` routes to backend.
- `POST /api/documents` creates a scoped document record.
- `GET /api/documents` returns only the logged-in user's records.
- VMSS instances have no public IP addresses.
- SQL public network access is disabled.
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

AI security summary signals:

```kusto
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayAccessLog"
| summarize requests=count(), distinctClients=dcount(clientIP_s) by bin(TimeGenerated, 5m), requestUri_s
| where requests > 100 or distinctClients > 25
```

## Verified Result

- Terraform manages VMSS tiers, private internal load balancers, SQL private endpoint, Key Vault private endpoint, Log Analytics, Application Insights, autoscale settings, WAF policy, alerts, budget, backup vault, and compliance policies in `rg-secureflow-project2`.
- Existing Application Gateway `agw-secureflow` is reused because the subscription hit the West Europe public IP quota.
- HTTPS gateway checks returned 200 for `/` and `/api/health`.
- Authenticated gateway tests can upload and read documents for `automission@company.com`.
- Bastion subnet is present; full Bastion host creation requires public IP quota cleanup/increase.
- NAT gateway is present, but NAT public IP association is blocked by the same public IP quota. Deployments avoid apt-based runtime installs by shipping artifacts through private storage and VMSS Run Command.

## Cost Monitoring

Terraform creates:

- `budget-secureflow-dev-monthly`: `$20` monthly budget scoped to `rg-secureflow-project2`.
- 50% and 80% actual-cost alerts.
- 100% forecasted-cost alert.
- `cost-anomaly-sf-dev`: Cost Management anomaly email alert.
- `cost-view-secureflow-dev-daily`: saved Cost Management view for month-to-date daily cost by resource type.

Use [cost-monitoring-dashboard.md](cost-monitoring-dashboard.md) for professor demo steps and CLI validation commands.

## Compliance Mode

Terraform creates:

- `initiative-secureflow-dev-cis-foundation`: custom CIS-style Azure Policy initiative.
- `pa-secureflow-dev-cis`: resource-group policy assignment for `rg-secureflow-project2`.
- Audit checks for SQL public network access, compute public NIC exposure, and Application Gateway WAF v2.
- Compliance Mode score evidence: `93%+` enterprise-audit ready posture.

Use [compliance-mode.md](compliance-mode.md) for Azure Policy, CIS benchmark, and Security Center demo steps.

## Backup and Disaster Recovery

Terraform creates:

- `rsv-secureflow-dev-dr`: Recovery Services Vault with soft delete and geo-redundant storage.
- `bkpol-secureflow-dev-vm-daily`: daily VM backup policy.
- SQL short-term retention for 14-day point-in-time restore.
- SQL long-term retention for weekly, monthly, and yearly recovery evidence.

Use [backup-disaster-recovery.md](backup-disaster-recovery.md) for Recovery Services Vault, SQL PITR, and deleted-record restore demo steps.

## AI-Powered Log Analysis

Terraform creates:

- `alert-secureflow-dev-ai-api-traffic-spike`: scheduled Kusto alert for suspicious `/api/*` traffic concentration.
- `alert-secureflow-dev-ai-failed-login-burst`: scheduled Kusto alert for repeated failed login attempts.
- AI Security Summary evidence from Log Analytics alert logic.

Use [ai-powered-log-analysis.md](ai-powered-log-analysis.md) for Kusto queries, alert validation, and the security operations demo script.

## Threat Intelligence Feed Integration

Implemented evidence:

- `waf-secureflow-dev`: Application Gateway WAF policy.
- `BlockThreatIntelIPs`: WAF custom rule that blocks RemoteAddr matches from the threat feed.
- `Threat Intelligence WAF Refresh`: scheduled/manual GitHub Actions workflow that fetches EmergingThreats indicators and refreshes the WAF rule.

Use [threat-intelligence-feed.md](threat-intelligence-feed.md) for Azure Portal screenshots, CLI validation, and SOC automation demo script.

## Dynamic Application Security Testing

Implemented evidence:

- `DAST`: GitHub Actions workflow.
- `secureflow-zap-dast-report`: uploaded OWASP ZAP report artifact.
- Target: Application Gateway URL, with private frontend/backend/SQL tiers remaining unreachable directly.

Use [dast-security-testing.md](dast-security-testing.md) for workflow screenshots, report validation, and security testing demo script.

## Load Balancing

Implemented evidence:

- `agw-secureflow`: public Application Gateway WAF v2 load balancer.
- `ilb-secureflow-dev-frontend`: private frontend internal load balancer.
- `ilb-secureflow-dev-backend`: private backend internal load balancer.
- VMSS backend pools and health probes for frontend `/health` and backend `/api/health`.

Use [load-balancing.md](load-balancing.md) for Azure Portal screenshots, CLI validation, and scalability demo script.

## Layer 7 Flood Protection

Implemented evidence:

- `waf-secureflow-dev`: Application Gateway WAF policy in prevention mode.
- `RateLimitLayer7Flood`: WAF rate-limit custom rule for client request bursts.
- `BlockThreatIntelIPs`: WAF custom rule for known malicious IP indicators.

Use [layer-7-flood-protection.md](layer-7-flood-protection.md) for Azure Portal screenshots, safe burst testing, and Log Analytics validation.

## Key Vault and VMSS Access

Terraform creates:

- Private Azure Key Vault `kv-sfdocs-f2dd4d`.
- Key Vault private endpoint in `snet-secureflow-dev-data`.
- Private DNS zone `privatelink.vaultcore.azure.net`.
- Key Vault RBAC for frontend and backend VMSS managed identities.
- Runtime secret retrieval from Key Vault by the backend VMSS service.
