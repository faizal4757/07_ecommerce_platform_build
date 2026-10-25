with source as (

    select *
    from {{ source('olist_bronze', 'geolocation') }}

)

select
    cast(geolocation_zip_code_prefix as string) as geolocation_zip_code_prefix,
    cast(geolocation_lat as decimal(10, 7)) as geolocation_lat,
    cast(geolocation_lng as decimal(10, 7)) as geolocation_lng,
    trim(cast(geolocation_city as string)) as geolocation_city,
    upper(trim(cast(geolocation_state as string))) as geolocation_state
from source
