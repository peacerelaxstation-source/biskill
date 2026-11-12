-- Monthly net revenue with MoM and YoY growth.
-- Grain: one row per month. Dialect: Snowflake.
with monthly as (
    select
        date_trunc('month', order_date) as order_month,
        sum(net_revenue)                as net_revenue
    from analytics.fct_order_items
    where order_date >= dateadd('month', -36, date_trunc('month', current_date))
      and order_date <  date_trunc('month', current_date)   -- complete months only
    group by 1
),

with_comparisons as (
    select
        order_month,
        net_revenue,
        lag(net_revenue, 1)  over (order by order_month) as prior_month_revenue,
        lag(net_revenue, 12) over (order by order_month) as prior_year_revenue
    from monthly
)

select
    order_month,
    net_revenue,
    prior_month_revenue,
    prior_year_revenue,
    (net_revenue - prior_month_revenue) / nullif(prior_month_revenue, 0) as mom_growth_pct,
    (net_revenue - prior_year_revenue)  / nullif(prior_year_revenue, 0)  as yoy_growth_pct
from with_comparisons
order by order_month;

-- Note: lag(…, 12) assumes no missing months. If months can be absent,
-- join to a date spine (dim_date) first so every month has a row.
