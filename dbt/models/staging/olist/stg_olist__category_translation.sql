with source as (

    select *
    from {{ source('olist_bronze', 'category_translation') }}

)

select
    trim(cast(product_category_name as string)) as product_category_name,
    trim(cast(product_category_name_english as string)) as product_category_name_english
from source
