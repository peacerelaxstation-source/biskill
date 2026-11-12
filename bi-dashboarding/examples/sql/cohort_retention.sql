-- Monthly cohort retention: share of each acquisition cohort that orders
-- again N months later. Grain: one row per cohort month per month offset.
with first_orders as (
    select
        customer_id,
        date_trunc('month', min(order_date)) as cohort_month
    from analytics.fct_orders
    group by 1
),

activity as (
    select distinct
        o.customer_id,
        f.cohort_month,
        datediff('month', f.cohort_month, date_trunc('month', o.order_date)) as month_offset
    from analytics.fct_orders o
    join first_orders f using (customer_id)
),

cohort_sizes as (
    select cohort_month, count(*) as cohort_customers
    from first_orders
    group by 1
)

select
    a.cohort_month,
    a.month_offset,
    s.cohort_customers,
    count(distinct a.customer_id)                      as active_customers,
    count(distinct a.customer_id) / s.cohort_customers as retention_rate
from activity a
join cohort_sizes s using (cohort_month)
group by 1, 2, 3
order by 1, 2;

-- Retention is a ratio of distinct counts: non-additive. Pivot month_offset
-- into columns in the BI tool; never sum or average the rates across cohorts.
