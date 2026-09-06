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
        .option("cloudFiles.format", "csv")
        .option("cloudFiles.schemaLocation", schema_path)
        .option("cloudFiles.inferColumnTypes", "true")
        .option("header", "true")
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