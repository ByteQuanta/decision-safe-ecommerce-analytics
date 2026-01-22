with orders as (

    select *
    from {{ ref('bronze_orders') }}

),

metrics as (

    select
        count(*) as total_orders,

        sum(case when order_delivered_ts is null then 1 else 0 end) 
            as undelivered_orders,

        round(
            sum(case when order_delivered_ts is null then 1 else 0 end) 
            * 1.0 / count(*),
            4
        ) as undelivered_rate,

        sum(case when order_delivered_ts < order_purchase_ts then 1 else 0 end)
            as impossible_delivery_dates

    from orders

)

select *
from metrics
