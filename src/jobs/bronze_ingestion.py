import argparse

from ingestion.ingestion import ingest_to_bronze


parser = argparse.ArgumentParser()

parser.add_argument("--source-path", required=True)
parser.add_argument("--checkpoint-path", required=True)
parser.add_argument("--schema-path", required=True)
parser.add_argument("--target-table", required=True)

args = parser.parse_args()


query = ingest_to_bronze(
    spark=spark,
    source_path=args.source_path,
    checkpoint_path=args.checkpoint_path,
    schema_path=args.schema_path,
    target_table=args.target_table
)

query.awaitTermination()