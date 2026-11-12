-- Session funnel: visit -> product view -> add to cart -> purchase.
-- Grain of result: one row per day. A session counts for a step only if it
-- also reached every earlier step.
with session_steps as (
    select
        session_id,
        min(event_ts)::date                                as session_date,
        max(iff(event_name = 'product_view', 1, 0))        as viewed,
        max(iff(event_name = 'add_to_cart', 1, 0))         as carted,
        max(iff(event_name = 'purchase', 1, 0))            as purchased
    from analytics.fct_web_events
    where event_ts >= dateadd('day', -90, current_date)
    group by 1
)

select
    session_date,
    count(*)                                               as sessions,
    sum(viewed)                                            as viewed_sessions,
    sum(viewed * carted)                                   as carted_sessions,
    sum(viewed * carted * purchased)                       as purchased_sessions,
    sum(viewed) / nullif(count(*), 0)                      as view_rate,
    sum(viewed * carted) / nullif(sum(viewed), 0)          as cart_rate,
    sum(viewed * carted * purchased)
        / nullif(sum(viewed * carted), 0)                  as purchase_rate,
    sum(viewed * carted * purchased) / nullif(count(*), 0) as overall_conversion
from session_steps
group by 1
order by 1;
