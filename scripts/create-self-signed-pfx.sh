#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-/private/tmp/secureflow-cert}"
COMMON_NAME="${COMMON_NAME:-secureflow.local}"
PASSWORD="${PFX_PASSWORD:-ChangeMe-Use-KeyVault-For-Real-Deployments}"

mkdir -p "$OUT_DIR"
openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout "$OUT_DIR/appgw.key" \
  -out "$OUT_DIR/appgw.crt" \
  -days 365 \
  -subj "/CN=$COMMON_NAME"

openssl pkcs12 -export \
  -out "$OUT_DIR/appgw.pfx" \
  -inkey "$OUT_DIR/appgw.key" \
  -in "$OUT_DIR/appgw.crt" \
  -password "pass:$PASSWORD"

base64 < "$OUT_DIR/appgw.pfx" | tr -d '\n' > "$OUT_DIR/appgw.pfx.b64"
echo "PFX base64: $OUT_DIR/appgw.pfx.b64"
echo "PFX password: $PASSWORD"
