with audit as (

    select *
    from {{ ref('audit_orders_quality') }}

),

thresholds as (

    select
        0.05 as max_undelivered_rate
),

decision as (

    select
        audit.total_orders,
        audit.undelivered_rate,
        thresholds.max_undelivered_rate,

        case
            when audit.undelivered_rate <= thresholds.max_undelivered_rate
                then true
            else false
        end as allow_analytics

    from audit
    cross join thresholds

)

select *
from decision
