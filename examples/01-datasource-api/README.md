# 01 — Datasource API: Provisioning a Prometheus Datasource (UID Path)

**Evidence level: design-only, gate 1 target.** This pattern has not been
runtime-validated on the fleet. It is written from the Grafana 13.2.4
documentation and the fleet's Grafana installs (see Versions). Do not
describe it as fleet-verified until a gate-3 run exists.

## What it demonstrates

Provisioning a Prometheus datasource through the Grafana HTTP API, and
then addressing it by UID — the path that works in Grafana 13. The
fleet's recorded quirk is the point of this pattern: the UID proxy path
works, the numeric-id path 404s in Grafana 13. Do not use numeric ids.

## Files

- `create_datasource.sh` — login, create, read-back by UID, and a
  UID-proxied Prometheus query.

## Run

```bash
export GRAFANA_URL=http://localhost:3000
export GRAFANA_USER=your_admin_user
export GRAFANA_PASSWORD=your_admin_password
export PROMETHEUS_URL=http://localhost:9090
bash create_datasource.sh
```

Run this against a **dev Grafana instance** (or your own). Never run
it against a fleet Grafana: the fleet's provisioning and dashboards
are verify-only scope elsewhere, and the fleet admin credential changed
under Tier A — it lives only in restricted files and is never recorded
here. All credential values above are placeholders.

## Synthetic inputs

None — the datasource points at a Prometheus URL you supply (default
`http://localhost:9090`, the fleet's Prometheus port). The queries use
the `up` metric, which every Prometheus serves.

## Expected output

- `POST /api/datasources` returns **200** with a JSON body containing
  a server-assigned `uid`. The script captures that UID; it never
  invents one.
- `GET /api/datasources/uid/<uid>` returns **200** with the same
  datasource (name `Prometheus-dev`, type `prometheus`).
- The UID-proxied query
  `GET /api/datasources/proxy/uid/<uid>/api/v1/query?query=up`
  returns **200** with a `data.result` list.
- The numeric-id variant (`/api/datasources/proxy/1/...`) is expected
  to **404 in Grafana 13** — that is the documented fleet quirk, and
  the script does not use it.

## Versions

- Grafana **13.2.4** (fleet-verified on Node-1, Node-3, Node-4).
  Grafana 13 ships `grafana.exe server` — there is no
  `grafana-server.exe` in v13; do not script around the old binary
  name.
- Prometheus 3.15.1 (fleet-verified on Node-1, Node-3, Node-4).
- Fleet shape evidence: Node-1's datasource `Prometheus`, id 1, UID
  `fg29jfimdqb5sb`, proxy via UID path works; Node-4's datasource UID
  `ag2bk1p7knshsd` (auto-generated). This example creates a fresh
  datasource named `Prometheus-dev` — it never reuses a fleet name or
  UID, and never overwrites an existing datasource.
- To confirm at validation: the exact JSON field names in the create
  response for 13.2.4, and the exact error body for a duplicate-name
  create.

## Failure behavior

- Duplicate name: the create call fails (name collision). Use a fresh
  name; do not delete or overwrite an existing datasource to make
  room. The fleet record warns against reusing datasource names/UIDs
  when provisioning — treat a collision as a stop, not a prompt to
  force.
- 401 on any call: the admin credentials are wrong or the session
  expired. Re-login with your own dev-instance credentials; never
  reach for a fleet credential.
- Prometheus unreachable: the create still succeeds (Grafana does not
  validate the URL at create time), but the proxied query fails.
  Fix the Prometheus URL and re-run the query step only.

## To confirm at validation

- Exact create-response JSON for Grafana 13.2.4.
- Exact duplicate-name error body and status code.
- Whether the proxied query path above is the canonical UID path in
  13.2.4 or whether the fleet's working UID path used a different
  spelling (the quirk is recorded; the spelling is re-verified here).
