# 03 — Alerts: Rules and Notification Channels

**Evidence level: design-only, gate 1 target.** This pattern has not been
runtime-validated on the fleet. It is written from the Grafana 13.2.4
documentation and the fleet's Grafana installs (see Versions). Do not
describe it as fleet-verified until a gate-3 run exists.

## What it demonstrates

A unified-alerting rule (Grafana 9+ shape, as shipped in 13): fire when
a scrape target stays down, wait out a pending window, then notify a
contact point. The rule and the contact point are separate objects —
the rule decides *when*, the contact point decides *where*.

## Files

- `alert_rule.json` — the alert rule: `WindowsExporterDown`, expression
  `up{job="windows_exporter"} == 0`, pending 5 minutes.
- `contact_point.json` — a placeholder webhook contact point. The URL
  is a placeholder and the channel is NOT wired to anything real.

## Run

Create the contact point first, then the rule, via the Grafana API
(login as in pattern 01, dev instance only):

```bash
export GRAFANA_URL=http://localhost:3000
curl -s -b /tmp/grafana-cookies.txt -X POST \
  -H "Content-Type: application/json" \
  -d @contact_point.json "$GRAFANA_URL/api/v1/provisioning/contact-points"
curl -s -b /tmp/grafana-cookies.txt -X POST \
  -H "Content-Type: application/json" \
  -d @alert_rule.json "$GRAFANA_URL/api/v1/provisioning/alert-rules"
```

## Synthetic inputs

None — the rule evaluates the `up` metric from Prometheus. To see it
fire in a dev environment, stop the windows_exporter target (pattern
04's scrape config) and wait out the 5-minute pending window.

## Expected output

- Both creates return **201** (or 200 where Grafana 13 returns 200 for
  an existing name — see Failure behavior).
- While the target is up: rule state **Normal**, no notifications.
- After 5 minutes down: rule state **Firing**, one notification to the
  placeholder channel. In this design-only pattern the channel is a
  placeholder URL, so "notification sent" means Grafana attempted
  delivery to the placeholder — it does not mean a human was reached.
- When the target recovers: rule state **Normal** again, with a
  resolved notification to the same channel.

## Versions

- Grafana **13.2.4** (fleet-verified on Node-1, Node-3, Node-4).
- Prometheus 3.15.1; windows_exporter 0.32.0.
- To confirm at validation: the exact provisioning-API payload shapes
  for 13.2.4 (rule groups, contact-point receivers, notification
  policies), which differ in detail across Grafana versions — the
  files here are written to the documented 13.x shape and must be
  re-verified field by field at validation.

## Failure behavior

- Duplicate rule/contact-point name: the create fails or overwrites
  depending on the endpoint. Use fresh names; never overwrite a fleet
  rule or contact point to make room.
- Rule created but never fires: check the datasource the rule queries
  (pattern 01's `Prometheus-dev` by reference) and the `for: 5m`
  window — a target down for 4 minutes is Pending, not Firing, by
  design. Do not shorten the window to "prove" firing.
- Notification channel misconfigured: Grafana reports delivery errors
  on the contact point. Real channels (email, chat, webhook endpoints)
  are Alex's decision — this pattern wires none of them.

## To confirm at validation

- Exact provisioning payloads for Grafana 13.2.4 (rule group UID,
  interval, notification policy routing).
- The state-transition timing (Pending → Firing at 5 minutes) on a
  live dev instance.
