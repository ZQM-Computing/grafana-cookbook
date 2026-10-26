#!/bin/bash
# Grafana 01-datasource-api: provision a Prometheus datasource via the
# API and address it by UID (the path that works in Grafana 13).
# Design-only pattern (gate 1 target). Run against a DEV Grafana only.
# Credentials come from the environment (placeholders in the README).
# Never run this against a fleet Grafana; never reuse a fleet name/UID.
set -euo pipefail

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_USER="${GRAFANA_USER:-your_admin_user}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-your_admin_password}"
PROMETHEUS_URL="${PROMETHEUS_URL:-http://localhost:9090}"

echo "== login =="
# Grafana 13 session login returns a grafana_session cookie.
curl -s -c /tmp/grafana-cookies.txt -X POST \
  -H "Content-Type: application/json" \
  -d "{\"user\": \"$GRAFANA_USER\", \"password\": \"$GRAFANA_PASSWORD\"}" \
  "$GRAFANA_URL/login" > /tmp/grafana-login.json
echo "login response bytes: $(wc -c < /tmp/grafana-login.json)"

echo "== create datasource (fresh name, server-assigned UID) =="
curl -s -b /tmp/grafana-cookies.txt -X POST \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Prometheus-dev\", \"type\": \"prometheus\",
       \"access\": \"proxy\", \"url\": \"$PROMETHEUS_URL\",
       \"isDefault\": false}" \
  "$GRAFANA_URL/api/datasources" > /tmp/grafana-ds.json
UID=$(python3 -c "import json; print(json.load(open('/tmp/grafana-ds.json'))['datasource']['uid'])")
echo "created datasource UID: $UID"

echo "== read back by UID =="
curl -s -b /tmp/grafana-cookies.txt \
  "$GRAFANA_URL/api/datasources/uid/$UID" | head -c 400
echo

echo "== UID-proxied Prometheus query (numeric-id path 404s in v13; unused) =="
curl -s -b /tmp/grafana-cookies.txt \
  "$GRAFANA_URL/api/datasources/proxy/uid/$UID/api/v1/query?query=up" \
  | head -c 400
echo
echo "DONE: datasource $UID provisioned and addressed by UID"
