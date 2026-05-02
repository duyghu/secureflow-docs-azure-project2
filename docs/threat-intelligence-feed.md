# Threat Intelligence Feed Integration

SecureFlow Docs includes SOC-style threat intelligence blocking at the only public ingress point: the Application Gateway WAF policy.

## Implemented Controls

- WAF policy: `waf-secureflow-dev`
- Custom rule: `BlockThreatIntelIPs`
- Rule priority: `50`
- Action: `Block`
- Match variable: `RemoteAddr`
- Operator: `IPMatch`
- Baseline feed source: EmergingThreats firewall block IP feed
- Automation: GitHub Actions workflow `Threat Intelligence WAF Refresh`

The Terraform baseline keeps the control reproducible. The workflow can refresh the WAF custom rule from the public EmergingThreats feed on a daily schedule or by manual dispatch.

## Why It Matters

This is a lightweight SOC automation pattern. Known hostile IP addresses are stopped at the WAF before traffic reaches private frontend, backend, or data tiers.

## Azure Portal Demo Steps

1. Open Azure Portal.
2. Go to Resource groups.
3. Select `group1_final`.
4. Open `waf-secureflow-dev`.
5. Open Custom rules.
6. Show `BlockThreatIntelIPs`.
7. Show match condition:
   - Match variable: `RemoteAddr`
   - Operator: `IPMatch`
   - Action: `Block`
8. Open GitHub Actions.
9. Show workflow `Threat Intelligence WAF Refresh`.
10. Explain that the workflow fetches the threat feed and updates the WAF custom rule automatically.

## CLI Validation

```bash
az network application-gateway waf-policy custom-rule show \
  --resource-group group1_final \
  --policy-name waf-secureflow-dev \
  --name BlockThreatIntelIPs \
  --query "{name:name,priority:priority,action:action,state:state,ruleType:ruleType,matchValues:matchConditions[0].matchValues}" \
  -o json
```

## Demo Talk Track

- "The Application Gateway WAF is our only public ingress, so it is the right place to enforce threat intelligence."
- "Terraform creates a baseline WAF custom rule named `BlockThreatIntelIPs`."
- "The GitHub Actions workflow refreshes that rule from the EmergingThreats public feed."
- "Known malicious clients are blocked before they can reach our private web, API, or SQL tiers."
- "In production this could be extended with AbuseIPDB, AlienVault OTX, Microsoft Sentinel, or Azure Firewall Premium threat intelligence."
