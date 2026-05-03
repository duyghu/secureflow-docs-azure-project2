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
