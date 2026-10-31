with source as (

    select *
    from {{ source('olist_bronze', 'products') }}

)

select
    cast(product_id as string) as product_id,
    trim(cast(product_category_name as string)) as product_category_name,
    cast(product_name_length as int) as product_name_length,
    cast(product_description_length as int) as product_description_length,
    cast(product_photos_qty as int) as product_photos_qty,
    cast(product_weight_g as int) as product_weight_g,
    cast(product_length_cm as decimal(10, 2)) as product_length_cm,
    cast(product_height_cm as decimal(10, 2)) as product_height_cm,
    cast(product_width_cm as decimal(10, 2)) as product_width_cm
from source
