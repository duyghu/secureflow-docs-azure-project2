# Cost Monitoring Dashboard

SecureFlow Docs includes a small FinOps control set so the project is not only deployable, but also operated with spending guardrails.

## Implemented Controls

- Resource group monthly budget: `budget-secureflow-dev-monthly`
- Budget amount: `$20` per month by default
- Actual spend alerts:
  - 50% of budget
  - 80% of budget
- Forecasted spend alert:
  - 100% of monthly budget
- Cost anomaly alert:
  - `cost-anomaly-sf-dev`
  - Sends email when Azure Cost Management detects unusual subscription spend
- Cost Management view:
  - `cost-view-secureflow-dev-daily`
  - Month-to-date daily cost by Azure resource type

## Why It Matters

This mirrors production FinOps practice: teams should detect overspend before the bill arrives, investigate unexpected usage changes, and keep infrastructure demos inside a predictable budget.


## CLI Validation

```bash
az consumption budget show \
  --resource-group group1_final \
  --budget-name budget-secureflow-dev-monthly \
  --query "{name:name,amount:amount,timeGrain:timeGrain,notifications:notifications}" \
  -o json
```

```bash
az costmanagement query \
  --scope /subscriptions/<subscription-id>/resourceGroups/group1_final \
  --type ActualCost \
  --timeframe MonthToDate \
  --dataset-granularity Daily \
  --dataset-aggregation name=totalCost function=Sum \
  --dataset-grouping name=ResourceType type=Dimension \
  -o table
```

```bash
az rest \
  --method get \
  --url "https://management.azure.com/subscriptions/<subscription-id>/providers/Microsoft.CostManagement/scheduledActions/cost-anomaly-sf-dev?api-version=2025-03-01"
```
