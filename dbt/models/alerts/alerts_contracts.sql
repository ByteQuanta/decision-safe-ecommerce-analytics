{{ config(materialized='table') }}

with contracts as (

    select *
    from {{ ref('contracts_orders') }}

),

alerts as (

    select
        current_timestamp as alert_ts,
        'contracts_orders' as contract_name,
        total_orders,
        undelivered_rate,
        max_undelivered_rate,
        allow_analytics,

        case
            when allow_analytics = false
                then 'BLOCKING'
            else 'OK'
        end as alert_severity,

        case
            when allow_analytics = false
                then 'Undelivered rate exceeded contract threshold'
            else null
        end as alert_reason

    from contracts

)

select *
from alerts
where allow_analytics = false
