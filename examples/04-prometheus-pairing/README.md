# 04 — Prometheus Pairing: Scrape Jobs for a Full Stack View

**Evidence level: design-only, gate 1 target.** This pattern has not been
runtime-validated on the fleet. It is written from the Prometheus 3.15.1
and Grafana 13.2.4 documentation and the fleet's observability installs
(see Versions). Do not describe it as fleet-verified until a gate-3 run
exists.

## What it demonstrates

Pairing Grafana with Prometheus scrape jobs for a full stack view: the
scrape config that feeds the dashboards (pattern 02) and alerts
(pattern 03), and the health checks that prove both jobs are up. This
is the other half of the Grafana datasource in pattern 01 — the
datasource points at Prometheus, and this pattern shows what Prometheus
must scrape for that datasource to be useful.

## Files

- `prometheus.yml` — scrape config: `prometheus` on :9090 and
  `windows_exporter` on :9182 (the fleet's job names and ports).
- `checks.sh` — health checks: Prometheus ready, both targets up.

## Run

Against a **standalone/dev Prometheus** (never the fleet's — fleet
provisioning is verify-only scope elsewhere):

```bash
prometheus --config.file=prometheus.yml --web.listen-address=:9090
bash checks.sh
```

Then point a Grafana datasource at `http://localhost:9090` (pattern
01) and import the pattern 02 dashboard.

## Synthetic inputs

None — the checks query Prometheus's own `up` metric and target list.
The scrape targets are `localhost:9090` (Prometheus itself) and
`localhost:9182` (windows_exporter). On a dev machine without
windows_exporter running, the second job reports down — that is the
correct signal, and it is what pattern 03's alert fires on.

## Expected output

- `GET /-/healthy` and `GET /-/ready` return **200**.
- `GET /api/v1/targets?state=active` lists both jobs.
- Query `up` returns **1 for both jobs** on a fully running dev
  stack — matching the fleet's Node-1 evidence (`up=1` for both scrape
  jobs). With windows_exporter absent, `up{job="windows_exporter"}`
  is **0** (or absent) and `up{job="prometheus"}` is **1**.
- The pattern 02 dashboard renders from this Prometheus; the pattern
  03 rule evaluates against it.

## Versions

- Prometheus **3.15.1** (fleet-verified on Node-1, Node-3, Node-4).
- windows_exporter **0.32.0** (fleet-verified; `:9182` via
  `--web.listen-address` — `--telemetry.addr` is unknown in 0.32.0).
- Grafana 13.2.4 as the consumer (pattern 01).
- To confirm at validation: the exact `/api/v1/targets` response shape
  for Prometheus 3.15.1, and whether `up` for a missing target is 0 or
  absent in this version (both readings are handled in the checks).

## Failure behavior

- Prometheus fails to start on :9090: the port is taken (fleet
  Prometheus, or another process). Pick a free port and update the
  datasource URL to match; do not stop a fleet service to free a port.
- Target down: `up` is 0 or absent. Check the exporter process first,
  then the scrape config's target address — a typo'd port is the
  common cause, and it looks identical to a dead exporter in `up`.
- Config reload failure: Prometheus logs the YAML error and keeps the
  old config. Fix the YAML and reload again; a failed reload never
  takes down scraping.

## To confirm at validation

- Exact `/-/healthy` vs `/-/ready` semantics for Prometheus 3.15.1
  (both 200 on the fleet's Node-3, but the distinction matters for
  readiness gating).
- The `up` value for a configured-but-absent target (0 vs absent).
