# AI-Powered Log Analysis

SecureFlow Docs includes an AI-assisted security analytics layer for WAF activity, API traffic spikes, and failed login bursts.

## Implemented Controls

- Log source: Application Gateway access logs.
- Log source: Application Gateway WAF logs.
- Log source: Application Insights request telemetry.
- Analytics engine: Log Analytics Kusto queries.
- Alert: `alert-secureflow-dev-ai-api-traffic-spike`
- Alert: `alert-secureflow-dev-ai-failed-login-burst`
- Presentation evidence: `AI Security Summary` generated from Azure monitoring signals

This implementation uses deterministic anomaly rules that are easy to explain in a class demo. The summary can later be connected to Azure OpenAI or the OpenAI API for natural-language incident narrative generation.

## Detection Logic

### API Traffic Spike

The detector groups Application Gateway logs by source IP and request URI. It flags concentrated traffic against `/api/*` paths when one source produces more than `100` requests in a `5` minute bucket.

Presentation phrasing:

> Traffic pattern resembles Layer 7 DoS behavior targeting `/api/*` endpoints.

### Failed Login Burst

The detector groups Application Insights request logs for `/api/auth/login` failures. It flags more than `5` failed attempts from the same client signal within a `5` minute bucket.

Presentation phrasing:

> Repeated failed authentication pattern resembles credential stuffing or brute-force activity.

## Kusto Queries

### WAF and API Spike Query

```kusto
AzureDiagnostics
| where TimeGenerated > ago(10m)
| where Category in ("ApplicationGatewayAccessLog", "ApplicationGatewayFirewallLog")
| extend RequestUri = tostring(column_ifexists("requestUri_s", ""))
| extend ClientIP = tostring(column_ifexists("clientIP_s", "unknown"))
| where RequestUri startswith "/api"
| summarize RequestCount = count() by bin(TimeGenerated, 5m), ClientIP, RequestUri
| where RequestCount > 100
```

### Failed Login Burst Query

```kusto
let FailedLoginRequests = union isfuzzy=true
  (requests
    | project TimeGenerated = timestamp, Url = tostring(url), ResultCode = tostring(resultCode), ClientIP = tostring(client_IP)),
  (AppRequests
    | project TimeGenerated, Url = tostring(Url), ResultCode = tostring(ResultCode), ClientIP = tostring(ClientIP));
FailedLoginRequests
| where TimeGenerated > ago(10m)
| where Url has "/api/auth/login"
| where ResultCode in ("401", "403")
| summarize FailedAttempts = count() by bin(TimeGenerated, 5m), ClientIP
| where FailedAttempts > 5
```

## Azure Portal Demo Steps

1. Open Azure Portal.
2. Go to Log Analytics workspaces.
3. Open `law-secureflow-dev`.
4. Run the WAF/API spike query.
5. Run the failed login burst query.
6. Go to Monitor > Alerts.
7. Show `alert-secureflow-dev-ai-api-traffic-spike`.
8. Show `alert-secureflow-dev-ai-failed-login-burst`.
9. Open the SecureFlow web app.
10. Show the `AI Security Summary` evidence from this runbook and the Azure Monitor alert rules.

## CLI Validation

```bash
az monitor scheduled-query list \
  --resource-group group1_final \
  --query "[?contains(name, 'ai-')].{name:name,enabled:enabled,severity:severity}" \
  -o table
```

```bash
az monitor log-analytics query \
  --workspace law-secureflow-dev \
  --analytics-query "AzureDiagnostics | where TimeGenerated > ago(30m) | summarize Count=count() by Category" \
  -o table
```

## Demo Talk Track

- "This is not just monitoring; it is security signal interpretation."
- "Application Gateway and WAF logs flow into Log Analytics."
- "Kusto rules detect API traffic concentration and failed-login bursts."
- "The runbook summarizes those detections as an AI Security Summary for executives."
- "A future enhancement can send the same query output to Azure OpenAI or OpenAI API to generate incident narratives automatically."
