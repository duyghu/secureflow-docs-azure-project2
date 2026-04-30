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

## Azure Portal Demo Steps

1. Open Azure Portal.
2. Go to Resource groups.
3. Select `group1_final`.
4. Open Cost Management.
5. Open Budgets and show `budget-secureflow-dev-monthly`.
6. Show alert thresholds: 50% actual, 80% actual, 100% forecasted.
7. Open Cost analysis and select the saved view `SecureFlow Docs daily resource cost`.
8. Change grouping to Resource type if needed and show App Gateway, VMSS, SQL, storage, and monitoring spend.
9. Go to Cost alerts and show active budget/anomaly alert configuration.

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

## Demo Talk Track

- "The app is protected by WAF and private networking, but production also needs cost controls."
- "Terraform creates a `$20` monthly resource-group budget."
- "Actual cost alerts fire at 50% and 80%; forecasted cost alerts fire if Azure predicts the project will exceed `$20`."
- "Cost anomaly detection catches unusual daily spend patterns, which is useful when a VM size, scale rule, or gateway setting accidentally increases cost."
- "The saved Cost Management view gives a dashboard-style breakdown of month-to-date cost by resource type."
