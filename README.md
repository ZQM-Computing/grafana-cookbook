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

**Status:** Active, public — seeding. Pattern passes land in follow-up work from fleet-verified setups; the tables below list what is planned, not what is already written.

**What this repository is:** Grafana patterns — see the table below.

**What it contributes:** Part of the ZQM Computing geospatial portfolio. The umbrella index for the series is [geospatial-cookbooks](https://github.com/ZQM-Computing/geospatial-cookbooks).

**Standing:** This repository is maintained independently. Automated checks cover only the paths and environments configured in its workflows; they do not establish production readiness or operational certification.

## Who this is for

Platform engineers who visualize fleet and service health.

## Prerequisites

- Grafana 13.2.4
- Prometheus as a datasource (see prometheus-cookbook)
- Bash or PowerShell for the API passes

## Patterns (planned)

| # | Example | What it will demonstrate |
|---|---------|--------------------------|
| 01 | `01-datasource-api` | Provisioning a Prometheus datasource via the API (UID path) |
| 02 | `02-dashboard` | Building a dashboard from panels and variables |
| 03 | `03-alerts` | Alert rules and notification channels |
| 04 | `04-prometheus-pairing` | Pairing with Prometheus scrape jobs for a full stack view |

## Repository layout

```text
grafana-cookbook/
├── examples/          # pattern passes, landing in follow-up work
├── README.md
└── LICENSE
```

## Roadmap

- First pattern pass: the first two table rows
- Second pass: the remaining rows, from fleet-verified setups

## Contributing

A contributing guide lands with the first pattern pass. Report security issues to <zqmcomputing@gmail.com> — please do not open a public issue for those.

## More from this series

- [prometheus-cookbook](https://github.com/ZQM-Computing/prometheus-cookbook) — Metrics, scrape jobs, PromQL, and alert rules
- [mosquitto-cookbook](https://github.com/ZQM-Computing/mosquitto-cookbook) — MQTT broker setup, listeners, and pub/sub patterns
- [geoserver-cookbook](https://github.com/ZQM-Computing/geoserver-cookbook) — Publishing, styling, federation, and securing OGC services
