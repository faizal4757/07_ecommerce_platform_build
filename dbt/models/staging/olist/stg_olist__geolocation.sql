with source as (

    select *
    from {{ source('olist_bronze', 'geolocation') }}

)

select
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
from source
