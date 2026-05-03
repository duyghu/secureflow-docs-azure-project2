# Compliance Mode

SecureFlow Docs includes an audit-ready Compliance Mode view for enterprise cloud governance evidence.


## Implemented Controls

### CIS Benchmark

Terraform creates a custom Azure Policy initiative named `initiative-secureflow-dev-cis-foundation`.

The initiative maps the project to CIS-style controls:

- SQL public network access must be disabled.
- Compute network interfaces must not expose public IP addresses.
- Public ingress must use Application Gateway WAF v2.

### Azure Policy

Terraform assigns the initiative to the project resource group with:

- Assignment: `pa-secureflow-dev-cis`
- Scope: `group1_final`
- Enforcement mode: disabled for audit-only reporting
- Non-compliance message describing the expected SecureFlow security baseline

Audit-only mode is intentional for the class project. It proves governance without accidentally blocking later demo changes.



## CLI Validation

```bash
az policy assignment show \
  --name pa-secureflow-dev-cis \
  --scope /subscriptions/<subscription-id>/resourceGroups/group1_final \
  --query "{name:name,displayName:displayName,enforcementMode:enforcementMode}" \
  -o table
```

```bash
az policy state summarize \
  --resource-group group1_final \
  --query "results[0].policyDetails[?contains(policyAssignmentName, 'pa-secureflow-dev-cis')]"
```

```bash
az security assessment list \
  --query "[].{name:name,status:status.code,display:displayName}" \
  -o table
```
