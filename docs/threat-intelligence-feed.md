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

## CLI Validation

```bash
az network application-gateway waf-policy custom-rule show \
  --resource-group group1_final \
  --policy-name waf-secureflow-dev \
  --name BlockThreatIntelIPs \
  --query "{name:name,priority:priority,action:action,state:state,ruleType:ruleType,matchValues:matchConditions[0].matchValues}" \
  -o json
```
