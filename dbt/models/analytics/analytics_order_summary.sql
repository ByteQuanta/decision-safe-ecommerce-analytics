{{ config(materialized='table') }}

select
    count(*) as total_orders,
    avg(
        case
            when order_delivered_ts is null then 1
            else 0
        end
    ) as undelivered_rate
from {{ ref('bronze_orders') }}
where
    (select allow_analytics from {{ ref('contracts_orders') }}) = true

