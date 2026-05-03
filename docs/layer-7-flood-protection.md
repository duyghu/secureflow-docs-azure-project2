# Layer 7 Flood Protection

SecureFlow Docs uses Application Gateway WAF custom rules for safe Layer 7 flood protection without enabling the expensive Azure DDoS Protection plan.

## Implemented Controls

- WAF policy: `waf-secureflow-dev`
- WAF mode: `Prevention`
- Threat intelligence rule: `BlockThreatIntelIPs`
- Rate-limit rule: `RateLimitLayer7Flood`
- Rule type: `RateLimitRule`
- Action: `Block`
- Grouping: client address
- Threshold: `120` requests per `1` minute
- Scope: all request URIs

This protects the public HTTP/HTTPS entry point from repeated client request floods. 


```kusto
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK"
| where Category == "ApplicationGatewayFirewallLog"
| where TimeGenerated > ago(30m)
| project TimeGenerated, clientIp_s, requestUri_s, action_s, ruleId_s, Message
| order by TimeGenerated desc
```
