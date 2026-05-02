# Dynamic Application Security Testing

SecureFlow Docs includes DAST so the deployed Azure application is tested from the outside, the same way a real attacker or security scanner would see it.

## Implemented Controls

- Scanner: OWASP ZAP baseline scan
- Runner: self-hosted GitHub Actions runner on the Azure ops VM in `group1_final`
- Target: public Application Gateway URL
- Default target: `https://135.116.238.100/`
- Workflow: `DAST`
- Artifact: `secureflow-zap-dast-report`
- Latest manual evidence: `docs/screenshots/secureflow-zap-report.md`
- Report formats:
  - `secureflow-zap-report.html`
  - `secureflow-zap-report.json`
  - `secureflow-zap-report.md`

The scan runs from the project Azure environment and validates the only public entry point, Application Gateway WAF. It checks the homepage and `/api/health`, then runs ZAP passive checks against the externally exposed site.

## Why It Matters

SAST and SonarQube inspect source code, but DAST tests the live deployed app. This helps prove that HTTPS, headers, cookies, routing, and exposed endpoints behave safely after deployment.

## GitHub Actions Demo Steps

1. Open GitHub repository.
2. Go to Actions.
3. Select workflow `DAST`.
4. Run workflow manually, or open the latest scheduled/manual run.
5. Show it runs on labels `self-hosted`, `Linux`, `X64`, `secureflow-ops`.
6. Open the uploaded artifact `secureflow-zap-dast-report`.
7. Screenshot the workflow success page and the HTML report summary.

## Azure Demo Steps

1. Open Azure Portal.
2. Go to Resource groups.
3. Select `group1_final`.
4. Open the ops VM `group1-final`.
5. Show it hosts the self-hosted GitHub runner.
6. Open Application Gateway `agw-secureflow-dev`.
7. Show the public frontend and `/api/health` are exposed only through App Gateway.
8. Explain that ZAP scans this public gateway URL while frontend/backend/SQL remain private.

## Local Validation

```bash
curl -k https://135.116.238.100/api/health
```

```bash
sudo docker run --rm \
  -v "$PWD/zap-reports:/zap/wrk:rw" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
    -t https://135.116.238.100/ \
    -r secureflow-zap-report.html \
    -J secureflow-zap-report.json \
    -w secureflow-zap-report.md \
    -I \
    -z "-config connection.sslAcceptAll=true"
```

## Latest Validation Result

The latest manual scan from the Azure ops VM completed with:

- URLs scanned: `4`
- Failed checks: `0`
- Warnings: `8`
- Passed passive checks: `59`

The warnings are mostly hardening headers such as HSTS, CSP, and Permissions-Policy. They are useful remediation evidence for the security section of the presentation.

## Demo Talk Track

- "SonarQube gives static security analysis, but DAST tests the deployed system from the outside."
- "The scan runs from our Azure self-hosted runner against the Application Gateway URL."
- "This validates the public attack surface while keeping VMSS and SQL private."
- "The ZAP report becomes evidence for live application security testing in our CI/CD pipeline."
