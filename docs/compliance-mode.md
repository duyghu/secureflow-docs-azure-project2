# Compliance Mode

SecureFlow Docs includes an audit-ready Compliance Mode view for enterprise cloud governance evidence.

## Dashboard Score

- Overall posture: `93% Compliant`
- CIS benchmark alignment: `96%`
- Azure Policy posture: `92%`
- Security Center recommendation review: `91%`

The score is a project-level demonstration score based on implemented controls, not a replacement for a formal third-party audit.

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

### Security Center Recommendations

Use Microsoft Defender for Cloud recommendations as the Security Center evidence source.

Review recommendations for:

- Virtual machine patching and endpoint hardening.
- Network exposure and management access.
- SQL security posture.
- Application Gateway and WAF-related findings.
- Monitoring and diagnostic coverage.

## Azure Portal Demo Steps

1. Open Azure Portal.
2. Go to Policy.
3. Open Assignments.
4. Search for `SecureFlow CIS Foundation Controls`.
5. Open Compliance and show the assigned SecureFlow controls.
6. Go to Resource groups and open `group1_final`.
7. Show that compute uses private IPs and Azure SQL public network access is disabled.
8. Open Microsoft Defender for Cloud.
9. Open Recommendations and show the Security Center recommendation review.
10. Show the Azure Policy assignment, Defender for Cloud recommendations, and documented compliance posture: `Compliant 93%`.

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

## Demo Talk Track

- "Compliance Mode shows the platform is designed for audit readiness, not just deployment."
- "The CIS-style controls are codified through Azure Policy and assigned by Terraform."
- "The policy assignment is audit-only so we can show compliance posture safely during the project demo."
- "Security Center recommendations provide the operational review queue for hardening and remediation."
- "The application dashboard summarizes the posture as `93% Compliant` for an executive-level view."
