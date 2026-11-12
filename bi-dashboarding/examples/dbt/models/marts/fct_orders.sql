-- Mart: one row per order. Business logic (exclusions, net revenue) lives here.
with orders as (
    select * from {{ ref('stg_orders') }}
    where not is_test_order
      and order_status <> 'cancelled'
)

select
    order_id,
    customer_id,
    order_date,
    order_status,
    gross_amount,
    discount_amount,
    refund_amount,
    gross_amount - discount_amount - refund_amount as net_revenue
from orders
