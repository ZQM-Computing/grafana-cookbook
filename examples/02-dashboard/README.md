# 02 — Dashboard: Panels and Variables

**Evidence level: design-only, gate 1 target.** This pattern has not been
runtime-validated on the fleet. It is written from the Grafana 13.2.4
documentation and the fleet's Grafana installs (see Versions). Do not
describe it as fleet-verified until a gate-3 run exists.

## What it demonstrates

Building a dashboard from panels and a template variable, as a
standalone JSON document you can import — without touching any fleet
dashboard. Two panels over the fleet's two scrape jobs, one variable
that switches the job being viewed.

## Files

- `dashboard.json` — the dashboard: 1 timeseries panel, 1 stat panel,
  1 template variable. UIDs left null so Grafana assigns fresh ones on
  import (never reuse a fleet dashboard UID).

## Run

Import via the Grafana UI (Dashboards → Import → paste the JSON), or
via the API:

```bash
export GRAFANA_URL=http://localhost:3000
# Log in as in pattern 01, then:
curl -s -b /tmp/grafana-cookies.txt -X POST \
  -H "Content-Type: application/json" \
  -d "{\"dashboard\": $(cat dashboard.json), \"overwrite\": false}" \
  "$GRAFANA_URL/api/dashboards/db"
```

Import into a **dev instance or a fresh folder**. Never import over a
fleet dashboard, never set `"overwrite": true` against a fleet UID, and
never edit the fleet's provisioned dashboards from this pattern.

## Synthetic inputs

None — the panels query the `up` metric from Prometheus, which every
Prometheus serves. The datasource reference in the JSON is the name
`Prometheus-dev` from pattern 01; point it at your own datasource if
yours differs.

## Expected output

- Import returns **200** with a fresh dashboard UID and URL.
- The dashboard renders **2 panels**: a timeseries of
  `up{job="$job"}` and a stat of `up{job="prometheus"}`.
- The `$job` variable dropdown lists the jobs Prometheus knows
  (`prometheus`, `windows_exporter` on a fleet-shaped instance).
- Switching `$job` re-queries the timeseries panel for that job only;
  the stat panel is unaffected (it is pinned to `prometheus`).

## Versions

- Grafana **13.2.4** (fleet-verified on Node-1, Node-3, Node-4).
- Prometheus 3.15.1; windows_exporter 0.32.0 (fleet scrape jobs).
- To confirm at validation: the exact dashboard JSON schema version
  Grafana 13.2.4 accepts on import, and whether `overwrite: false`
  rejects or renames on UID collision in 13.2.4.

## Failure behavior

- Import with a colliding UID: Grafana refuses or overwrites depending
  on the `overwrite` flag. This JSON ships null UIDs precisely so a
  collision cannot happen; if you set a UID by hand and collide, stop
  and pick a fresh one — never overwrite.
- Datasource name mismatch: panels show "datasource not found". Fix
  the datasource reference to your instance's name; do not rename a
  fleet datasource to match.
- Empty panels with no error: Prometheus has no `up` series yet
  (scrape not started). Start Prometheus with the pattern 04 scrape
  config first; an empty panel is a data problem, not a dashboard bug.

## To confirm at validation

- Exact import-response JSON for Grafana 13.2.4.
- The `label_values(up, job)` variable query behavior on a fresh
  instance (dropdown contents).
