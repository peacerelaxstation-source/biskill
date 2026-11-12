# biskill

A Claude skill for business intelligence and dashboarding: turning a business question into trustworthy metrics and a dashboard people actually use.

## What's here

```
bi-dashboarding/
├── SKILL.md                 # the skill: a 7-phase BI method
└── examples/
    ├── sql/                 # analytical SQL patterns (Snowflake dialect)
    │   ├── yoy_growth.sql
    │   ├── cohort_retention.sql
    │   └── funnel_conversion.sql
    └── dbt/models/          # staging -> marts layering with tests
        ├── staging/
        └── marts/
```

## The method

| Phase | Output |
|---|---|
| 1. Frame the question | Audience, decision, cadence, 3-5 KPIs |
| 2. Define metrics | Metric definition table (formula, grain, additivity) |
| 3. Model the data | Star schema with stated grains |
| 4. Write the SQL | CTE-based SQL / dbt models with tests |
| 5. Design the dashboard | KPI tiles -> trend -> breakdowns -> detail |
| 6. Build in the tool | Tableau, MicroStrategy, Power BI, Looker or HTML |
| 7. Validate | Reconciliation and grain checks before delivery |

## Using the skill

- **Claude Code**: copy the `bi-dashboarding/` folder into `~/.claude/skills/` (personal) or `.claude/skills/` in a project.
- **Claude app**: zip the `bi-dashboarding/` folder and upload it as a skill in Settings.

Then ask for BI work as usual, e.g. "define KPIs for a support-operations dashboard and write the Snowflake SQL".

## Examples

The examples use a generic e-commerce `orders` / `order_items` / `customers` schema and Snowflake SQL. They are illustrative patterns, not tied to any real dataset.
