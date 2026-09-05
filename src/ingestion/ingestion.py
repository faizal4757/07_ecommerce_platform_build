def ingest_to_bronze(
        spark,
        source_path,
        checkpoint_path,
        schema_path,
        target_table
):
    """
    Ingest data from a source path to a bronze table in Delta Lake.
    """

    stream = (
        spark.readStream
        .format("cloudFiles")  # not "couldFiles"
        .option("cloudFiles.format", "csv")
        .option("cloudFiles.schemaLocation", schema_path)
        .option("cloudFiles.inferColumnTypes", "true")
        .option("header", "true")
        .load(source_path)
    )

    query = (
        stream.writeStream     # not spark.writeStream
        .format("delta")
        .option("checkpointLocation", checkpoint_path)
        .trigger(availableNow=True)  # not ("availableNow", "true")
        .toTable(target_table)
    )

    return query