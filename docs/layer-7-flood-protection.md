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

This protects the public HTTP/HTTPS entry point from repeated client request floods. It is not a replacement for Azure DDoS Protection Network Protection, which is designed for volumetric Layer 3/4 attacks.

## Safe Test

Use a small request burst only. Do not perform destructive stress testing.

```bash
for i in {1..150}; do
  curl -k -s -o /dev/null https://135.116.238.100/api/health &
done
wait
```

Then check Application Gateway WAF logs in Log Analytics:

```kusto
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK"
| where Category == "ApplicationGatewayFirewallLog"
| where TimeGenerated > ago(30m)
| project TimeGenerated, clientIp_s, requestUri_s, action_s, ruleId_s, Message
| order by TimeGenerated desc
```

## Azure Portal Demo Steps

1. Open Azure Portal.
2. Go to Resource groups.
3. Select `group1_final`.
4. Open WAF policy `waf-secureflow-dev`.
5. Open Custom rules.
6. Show `RateLimitLayer7Flood`.
7. Show:
   - Type: Rate limit
   - Action: Block
   - Threshold: 120 requests
   - Duration: 1 minute
   - Group by: client address
8. Open Log Analytics workspace `law-secureflow-dev`.
9. Run the WAF log query after a safe request burst.

## Demo Talk Track

- "We did not enable Azure DDoS Protection because it is expensive for a student demo."
- "Instead, we added WAF-based Layer 7 flood protection at the only public entry point."
- "The WAF blocks a client that exceeds the configured request threshold."
- "For enterprise volumetric DDoS, the next step would be Azure DDoS Protection on the VNet or public IP."
