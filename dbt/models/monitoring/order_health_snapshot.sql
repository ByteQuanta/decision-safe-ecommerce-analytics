{{ 
  config(
    materialized='incremental',
    unique_key='snapshot_date'
  ) 
}}

select
    current_date as snapshot_date,
    total_orders,
    undelivered_rate
from {{ ref('audit_orders_quality') }}

{% if is_incremental() %}
where snapshot_date > (select max(snapshot_date) from {{ this }})
{% endif %}
