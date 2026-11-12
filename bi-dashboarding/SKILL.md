---
name: "bi-dashboarding"
description: "Use for business intelligence work: defining KPIs, modeling data, writing analytical SQL/dbt, and designing or building dashboards (Tableau, MicroStrategy, HTML)."
---

# BI & Dashboarding

A working method for turning a business question into trustworthy metrics and a dashboard people actually use. Work through the phases in order; skip a phase only when the user already supplied its output.

## Phase 1 — Frame the question

Before touching data, pin down:
- **Audience & decision**: who opens this dashboard, and what will they decide or do differently because of it?
- **Cadence**: real-time, daily, weekly, monthly? This drives refresh, grain and comparison periods.
- **Primary KPIs (3–5 max)** and the supporting breakdowns (by region, product, channel, cohort...).
- **Comparisons**: vs prior period, vs same period last year, vs target/plan.

If the user can't answer, propose a sensible default set and state it as an assumption at the top of the output.

## Phase 2 — Define metrics precisely

Write a metric definition table before any SQL. For each metric:

| Field | Example |
|---|---|
| Name | Net Revenue |
| Business definition | Gross bookings minus refunds and discounts |
| Formula | SUM(gross_amt) - SUM(refund_amt) - SUM(discount_amt) |
| Grain | Order line |
| Filters / exclusions | Exclude test accounts, internal orders |
| Time attribution | Order date (not ship date) |
| Additivity | Additive / semi-additive (balances) / non-additive (ratios, distinct counts) |
| Owner | Finance |

Rules:
- Ratios are computed as SUM(numerator) / SUM(denominator) at the display grain — never averaged across rows.
- Distinct counts are non-additive; never sum them across dimensions.
- Call out any metric whose definition is ambiguous and offer the two most likely readings.

## Phase 3 — Model the data

- Default to a **star schema**: one fact table per business process at a clearly stated grain, conformed dimensions (date, customer, product, geography).
- State the grain of every table in one sentence ("one row per order line per day").
- Use a date dimension for fiscal calendars, week definitions and holiday flags rather than date math scattered through queries.
- Handle slowly changing dimensions explicitly (Type 1 overwrite vs Type 2 history) and say which one each report needs.
- In a dbt project, layer as: `staging` (1:1 with sources, rename/cast only) → `intermediate` (joins, business logic) → `marts` (facts/dims consumed by BI). Add `unique` and `not_null` tests on keys and `relationships` tests on foreign keys.

## Phase 4 — Write the SQL

Match the dialect the user names (Snowflake, Teradata, Oracle, BigQuery, Postgres). Defaults:
- CTEs over nested subqueries; one logical step per CTE, named for what it holds.
- Explicit column lists, no `SELECT *` in final models.
- Window functions for period-over-period, running totals, ranking and deduplication (`QUALIFY ROW_NUMBER() ... = 1` where supported).
- Aggregate to the reporting grain before joining to avoid fan-out; check row counts before and after every join.
- Parameterize date ranges; never hard-code "today".

Common patterns to reach for: YoY/MoM growth, cohort retention matrix, funnel conversion, rolling 7/28-day averages, contribution/mix analysis, top-N with "Other".

## Phase 5 — Design the dashboard

Layout (top to bottom, the order people read):
1. **Title + filters bar** — date range, key slicers; show the data-as-of timestamp.
2. **KPI tiles** — current value, delta vs comparison period (absolute and %), small sparkline. Color the delta by whether it's good or bad, not by sign.
3. **Trend** — the primary KPI over time, with the comparison period or target as a reference line.
4. **Breakdowns** — what is driving the change (bar charts sorted descending, by dimension).
5. **Detail table** — for drill-down and export, last.

Chart choice:
- Change over time → line. Comparison across categories → horizontal bar, sorted. Part-to-whole with ≤5 parts → stacked bar (avoid pies beyond 3 slices). Distribution → histogram/box. Two measures' relationship → scatter. Matrix of two dimensions → heatmap.
- One message per chart; write the title as the takeaway ("Revenue up 12% YoY, driven by West") when the dashboard is static.
- Start bar axes at zero. Limit to ~6 colors; use one accent color for the thing that matters.
- If the dataviz skill is available, load it before writing chart code or picking colors.

## Phase 6 — Build in the target tool

- **Tableau**: provide calculated fields (with LOD expressions — FIXED/INCLUDE/EXCLUDE — where grain differs from the view), parameter definitions, recommended sheet list and dashboard layout, and extract vs live guidance.
- **MicroStrategy**: provide attributes, facts and metrics (with level/dimensionality settings for non-additive metrics), filters/prompts, and the dossier chapter/page layout.
- **Power BI / Looker**: DAX measures or LookML views/explores as appropriate.
- **Standalone/web**: build a self-contained HTML dashboard (or a Dashboard artifact if available) with the data embedded, filters wired up, and the layout from Phase 5.

## Phase 7 — Validate before delivering

Always run or describe these checks:
- Totals reconcile to a known source (finance report, source system count) within an agreed tolerance.
- No duplicate keys at the stated grain.
- Filters don't silently drop nulls (check "Unknown" buckets).
- Period-over-period math is correct at period boundaries (month ends, leap years, fiscal year rollover).
- Spot-check 2–3 individual records end to end.

Report what was checked and any discrepancy found; never present unreconciled numbers as final.

## Deliverables checklist

Depending on scope, hand back:
- Metric definition table (Phase 2)
- Data model sketch with grains (Phase 3)
- SQL / dbt models with tests (Phase 4)
- Dashboard wireframe or built dashboard (Phases 5–6)
- Validation notes and open assumptions (Phase 7)