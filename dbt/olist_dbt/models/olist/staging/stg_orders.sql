
{{ config(materialized='view') }}

WITH source AS (

    SELECT *
    FROM {{ source('olist', 'orders') }}

),

renamed AS (

    SELECT
        -- Business identifiers
        order_id,
        customer_id,

        -- Order attributes
        order_status,

        -- Business timestamps
        created_at,
        updated_at,
        order_approved_at,
        order_purchase_timestamp,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,

        -- Partition columns
        year,
        month,
        day,

        -- Airbyte metadata
        _airbyte_raw_id,
        _airbyte_extracted_at,
        _airbyte_generation_id,
        _airbyte_meta,

        -- CDC metadata
        _ab_cdc_lsn,
        _ab_cdc_deleted_at,
        _ab_cdc_updated_at,

        -- Data quality metadata
        _rescued_data

    FROM source

)

SELECT * FROM renamed
