#!/usr/bin/env bash
set -euo pipefail

GATEWAY_URL="${1:?Usage: scripts/validate-gateway.sh http://APP_GATEWAY_IP}"

echo "Checking frontend..."
curl -fsS "$GATEWAY_URL/" >/dev/null

echo "Creating document through /api..."
curl -fsS -X POST "$GATEWAY_URL/api/documents" \
  -H "Content-Type: application/json" \
  -d '{"title":"Demo NDA","category":"Contract","status":"Pending Approval","owner":"Legal","extractedSummary":"AI extracted parties, effective date, and signature status."}'

echo
echo "Reading documents through /api..."
curl -fsS "$GATEWAY_URL/api/documents"
echo
