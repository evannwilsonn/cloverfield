# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Hiring managers first, arriving from Evan Wilson's resume or LinkedIn and giving the page about a minute; they need to see that this is real monitoring of a real pipeline, and what it caught. Data and platform engineers second, who check whether the objectives, alerts and slot maths are sound. Desktop and phone viewing are about equal. (Confirmed for the whole portfolio on 2026-10-09.)

## Product Purpose

Cloverfield answers "is Cloverleaf working right now, and how reliably has it worked?" Cloverleaf records live Caltrans camera video every 30 minutes on a GitHub Actions schedule and turns it into traffic data. Cloverfield watches it from outside: GitHub's record of every run and step, and the files Cloverleaf's collector and daily build leave on its data branch. It computes service-level objectives over 24 hours and 7 days, raises alerts that clear themselves, and shows which cameras delivered a picture. Success: a reader can tell the current state in seconds and trust that it is measured, not asserted.

## Positioning

Monitoring built the way a data team would run it, as a separate product reading only external evidence, with explicit objectives and self-clearing alerts, applied to a pipeline whose failures are real (cameras go dark, GitHub skips scheduled runs).

## Operating Context

Static page with inline data, rebuilt hourly by a GitHub Actions workflow (DuckDB, Snowflake every sixth hour when secrets exist), also published as a Claude artifact. Sources: GitHub REST API (workflow runs, jobs, steps), Cloverleaf's data branch (captures JSONL, dbt run_results).

## Capabilities and Constraints

- Measures: scheduled slot outcomes (on time, late, missed, pending), run duration and step times, camera feed state per capture (live, no picture, frozen, offline, unreadable, live but dark), freshness, Cloverleaf's daily dbt build results.
- Five objectives with targets (seeds/slos.csv); five alert rules (seeds/alert_rules.csv).
- Every age is measured from when Cloverfield last read its sources, not page load time.
- Early life: the monitor started on 2026-10-09; history is short and the page must read honestly with little data.
- Every number on the page comes from data.json.

## Brand Commitments

Each portfolio project has its own visual world; a small shared signature may tie them to Evan. Cloverfield is the sibling of Cloverleaf (traffic) and should feel related to it in subject, not copied.

## Evidence on Hand

dashboard/data.json (status, slo, alerts, slots, runs, cameras, grid, builds). It currently shows real failures: GitHub has not yet fired Cloverleaf's 30-minute schedule, so data is stale and the overall state is Down; 6 of 20 cameras show placeholder cards, black frames or are offline. No users, testimonials or uptime history beyond this exist.

## Product Principles

1. State first: the current verdict is readable in one glance, then why.
2. Measured, not asserted: every status traces to a rule and a number.
3. Failures are shown as plainly as successes; an empty or early state is designed, not hidden.
4. Every control or mark maps to real data.

## Accessibility & Inclusion

WCAG AA contrast in light and dark; status never carried by colour alone; works at phone width.
