{{ config(materialized='table') }}

with snapshots as (

    select
        snapshot_date,
        undelivered_rate,
        lag(undelivered_rate) over (order by snapshot_date) as prev_rate
    from {{ ref('order_health_snapshot') }}

),

drift as (

    select
        snapshot_date,
        undelivered_rate,
        prev_rate,

        round(undelivered_rate - prev_rate, 4) as rate_change,

        case
            when prev_rate is not null
             and undelivered_rate > prev_rate * 1.2
                then true
            else false
        end as is_anomaly

    from snapshots

)

select *
from drift
where is_anomaly = true
