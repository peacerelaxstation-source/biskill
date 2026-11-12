-- Staging: 1:1 with the source, rename and cast only. No business logic.
with source as (
    select * from {{ source('shop', 'orders') }}
)

select
    id                          as order_id,
    customer_id,
    cast(created_at as date)    as order_date,
    lower(status)               as order_status,
    cast(gross_amount as number(18, 2))    as gross_amount,
    cast(discount_amount as number(18, 2)) as discount_amount,
    cast(refund_amount as number(18, 2))   as refund_amount,
    is_test_order
from source
