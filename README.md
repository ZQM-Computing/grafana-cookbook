# Grafana Cookbook

<!-- ZQM-START -->
<!-- markdownlint-disable MD033 -->
<p align="center">
  <strong>ZQM Computing — Geospatial Engineering & Scientific Computing</strong><br>
  <a href="https://github.com/ZQM-Computing">ZQM Computing</a>
</p>
<!-- markdownlint-enable MD033 -->
<!-- ZQM-END -->

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A **Grafana cookbook** for dashboards, datasources, and alerts for geospatial stacks. Patterns are drawn from the ZQM fleet's Grafana 13.2.4 installs on Node-1 and Node-3, including the v13 datasource-API quirk: the UID proxy path works, the numeric-id path 404s. Change the default admin credentials before exposing anything — that is a standing fleet follow-up, not a pattern. It is intended for Platform engineers who visualize fleet and service health. Validate each pattern against your own data, software versions, and operating environment before adopting it.

## Repository role and status

**Status:** Active, public — first pattern pass written (design-only, gate 1 target; runtime validation pending). The table below lists what is written; no pattern has been runtime-validated yet.

**What this repository is:** Grafana patterns — see the table below.

**What it contributes:** Part of the ZQM Computing geospatial portfolio. The umbrella index for the series is [geospatial-cookbooks](https://github.com/ZQM-Computing/geospatial-cookbooks).

**Standing:** This repository is maintained independently. Automated checks cover only the paths and environments configured in its workflows; they do not establish production readiness or operational certification.

## Who this is for

Platform engineers who visualize fleet and service health.

## Prerequisites

- Grafana 13.2.4
- Prometheus as a datasource (see prometheus-cookbook)
- Bash or PowerShell for the API passes

## Patterns

| # | Example | Status | What it demonstrates |
|---|---------|--------|----------------------|
| 01 | [01-datasource-api](examples/01-datasource-api/README.md) | Written (design-only) | Provisioning a Prometheus datasource via the API (UID path) |
| 02 | [02-dashboard](examples/02-dashboard/README.md) | Written (design-only) | Building a dashboard from panels and variables |
| 03 | [03-alerts](examples/03-alerts/README.md) | Written (design-only) | Alert rules and notification channels |
| 04 | [04-prometheus-pairing](examples/04-prometheus-pairing/README.md) | Written (design-only) | Pairing with Prometheus scrape jobs for a full stack view |

## Repository layout

```text
grafana-cookbook/
├── examples/01-datasource-api/      # API provisioning, UID path
├── examples/02-dashboard/           # panels + variables
├── examples/03-alerts/              # rules + contact points
├── examples/04-prometheus-pairing/  # scrape jobs + health checks
├── README.md
└── LICENSE
```

## Roadmap

- First pattern pass: complete (all 4 patterns, design-only).
- Next: gate-3 runtime validation against the fleet's Grafana installs.

## Contributing

A contributing guide lands with the first pattern pass. Report security issues to <zqmcomputing@gmail.com> — please do not open a public issue for those.

## More from this series

- [prometheus-cookbook](https://github.com/ZQM-Computing/prometheus-cookbook) — Metrics, scrape jobs, PromQL, and alert rules
- [mosquitto-cookbook](https://github.com/ZQM-Computing/mosquitto-cookbook) — MQTT broker setup, listeners, and pub/sub patterns
- [geoserver-cookbook](https://github.com/ZQM-Computing/geoserver-cookbook) — Publishing, styling, federation, and securing OGC services
