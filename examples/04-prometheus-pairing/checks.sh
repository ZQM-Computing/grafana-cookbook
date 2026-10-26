#!/bin/bash
# Grafana 04-prometheus-pairing — health checks for the scrape jobs.
# Design-only pattern (gate 1 target). Prometheus base URL from the env.
set -euo pipefail
PROM_URL="${PROM_URL:-http://localhost:9090}"
echo "== healthy / ready =="
curl -s -o /dev/null -w "healthy: %{http_code}\n" "$PROM_URL/-/healthy"
curl -s -o /dev/null -w "ready: %{http_code}\n" "$PROM_URL/-/ready"
echo "== up values (expect 1 per running job) =="
curl -s "$PROM_URL/api/v1/query?query=up" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for r in data['data']['result']:
    print(f\"{r['metric'].get('job', '?')}: {r['value'][1]}\")
"
echo "NOTE: up for a configured-but-absent target is 0 or absent"
echo "(Prometheus 3.15.1 behavior: to confirm at validation)."
