def ingest_to_bronze(
    spark,
    source_path,
    checkpoint_path,
    schema_path,
    target_table
):
    stream = (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "parquet")
        .option("cloudFiles.schemaLocation", schema_path)
        .load(source_path)
    )

    query = (
        stream.writeStream
        .format("delta")
        .option("checkpointLocation", checkpoint_path)
        .trigger(availableNow=True)
        .toTable(target_table)
    )

    return query