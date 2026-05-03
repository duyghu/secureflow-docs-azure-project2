# Load Balancing

SecureFlow Docs uses layered load balancing so the public edge and the private compute tiers can scale independently.

## Implemented Controls

- Public entry load balancer: Application Gateway WAF v2 `agw-secureflow-dev`
- Frontend internal load balancer: `ilb-secureflow-dev-frontend`
- Backend internal load balancer: `ilb-secureflow-dev-backend`
- Frontend ILB private IP: `10.2.2.10`
- Backend ILB private IP: `10.2.3.10`
- Frontend health probe: HTTP `/health` on port `80`
- Backend health probe: HTTP `/api/health` on port `8080`
- Frontend backend pool: frontend VMSS instances
- Backend backend pool: backend VMSS instances

Traffic path:

```text
Internet
  -> Application Gateway WAF v2
  -> private frontend/backend internal load balancer
  -> VMSS instance pool
  -> Azure SQL through private endpoint
```

Application Gateway still remains the only public entry. The internal load balancers do not have public IP addresses.


## CLI Validation

```bash
az network lb list \
  --resource-group group1_final \
  --query "[].{name:name,privateIp:frontendIPConfigurations[0].privateIPAddress,sku:sku.name}" \
  -o table
```

```bash
az network application-gateway address-pool list \
  --resource-group group1_final \
  --gateway-name agw-secureflow-dev \
  --query "[].{name:name,targets:backendAddresses[].ipAddress}" \
  -o table
```

```bash
az network application-gateway show-backend-health \
  --resource-group group1_final \
  --name agw-secureflow-dev \
  -o table
```
