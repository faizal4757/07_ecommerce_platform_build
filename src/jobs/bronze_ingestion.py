from ingestion.ingestion import ingest_to_bronze

SOURCE_PATH = "s3://olist-data-platform-raw/raw/olist/"

CHECKPOINT_PATH = (
    "s3://olist-data-platform-databricks/"
    "catalogue/checkpoints/bronze/orders/"
)

SCHEMA_PATH = (
    "s3://olist-data-platform-databricks/"
    "catalogue/schemas/bronze/orders/"
)

TARGET_TABLE = "01_ecommerce_dev.bronze.orders"


query = ingest_to_bronze(
    spark=spark,
    source_path=SOURCE_PATH,
    checkpoint_path=CHECKPOINT_PATH,
    schema_path=SCHEMA_PATH,
    target_table=TARGET_TABLE
)

query.awaitTermination()