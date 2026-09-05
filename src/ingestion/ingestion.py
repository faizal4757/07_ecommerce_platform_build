def ingest_to_bronze(
        spark,
        source_path,
        checkpoint_path,
        schema_path, 
        target_table
):
    """
    Ingest data from a source path to a bronze table in Delta Lake.

    Parameters:
    spark (SparkSession): The Spark session.
    source_path (str): The path to the source data.
    checkpoint_path (str): The path for the checkpoint directory.
    schema_path (str): The path to the schema definition file.
    target_table (str): The name of the target Delta table.

    Returns:
    None
    """
    stream = (
        spark.readStream
        .format("couldFiles")
        .option("cloudFiles.format", "csv")
        .option("cloudFiles.schemaLocation", schema_path)
        .option("cloudFiles.inferColumnTypes", "true")
        .option("header", "true")
        .load(source_path)
    )
    query = (
        spark.writeStream
        .format("delta")
        .option("checkpointLocation", checkpoint_path)
        .trigger("availableNow", "true")
        .toTable(target_table)
    )

    return query