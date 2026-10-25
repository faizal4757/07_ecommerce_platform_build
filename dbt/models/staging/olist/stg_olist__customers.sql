with source as (

    select *
    from {{ source('olist_bronze', 'customers') }}

)

select
    cast(customer_id as string) as customer_id,
    cast(customer_unique_id as string) as customer_unique_id,
    cast(customer_zip_code_prefix as string) as customer_zip_code_prefix,
    trim(cast(customer_city as string)) as customer_city,
    upper(trim(cast(customer_state as string))) as customer_state
from source
