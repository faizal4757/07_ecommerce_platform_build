with source as (

    select *
    from {{ source('olist_bronze', 'sellers') }}

)

select
    cast(seller_id as string) as seller_id,
    cast(seller_zip_code_prefix as string) as seller_zip_code_prefix,
    trim(cast(seller_city as string)) as seller_city,
    upper(trim(cast(seller_state as string))) as seller_state
from source
