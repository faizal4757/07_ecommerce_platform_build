with source as (

    select *
    from {{ source('olist_bronze', 'category_translation') }}

)

select
    product_category_name,
    product_category_name_english
from source
