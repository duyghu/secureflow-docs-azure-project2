#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-group1_final}"
FRONTEND_VMSS="${FRONTEND_VMSS:-vmss-secureflow-dev-frontend}"
BACKEND_VMSS="${BACKEND_VMSS:-vmss-secureflow-dev-backend}"
OUT="${1:-config/ansible/inventories/prod/hosts.ini}"

frontend_ips="$(az vmss nic list -g "$RESOURCE_GROUP" --vmss-name "$FRONTEND_VMSS" --query "[].ipConfigurations[].privateIPAddress" -o tsv)"
backend_ips="$(az vmss nic list -g "$RESOURCE_GROUP" --vmss-name "$BACKEND_VMSS" --query "[].ipConfigurations[].privateIPAddress" -o tsv)"

{
  echo "[frontend]"
  for ip in $frontend_ips; do
    echo "$ip ansible_user=azureuser"
  done
  echo
  echo "[backend]"
  for ip in $backend_ips; do
    echo "$ip ansible_user=azureuser"
  done
  echo
  echo "[sonarqube]"
  echo "127.0.0.1 ansible_connection=local"
  echo
  echo "[all:vars]"
  echo "ansible_python_interpreter=/usr/bin/python3"
} > "$OUT"

echo "Wrote $OUT"
