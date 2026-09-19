"""Historical extraction from PostgreSQL to the S3 raw landing zone.

This module performs the initial full snapshot for the Olist source tables.
It is intentionally separate from Databricks Bronze ingestion:

    PostgreSQL -> S3 raw/<dataset>/historical/ -> Databricks Auto Loader

Subsequent CDC/incremental loads will use the incoming/ prefix.
Ad-hoc reloads will use the backfill/ prefix.
"""

from __future__ import annotations

import os
import tempfile
from pathlib import Path
from typing import Iterable

import boto3
import psycopg


HISTORICAL_TABLES: tuple[str, ...] = (
    "category_translation",
    "customers",
    "geolocation",
    "order_items",
    "order_payments",
    "order_reviews",
    "orders",
    "products",
    "sellers",
)


def connect_to_postgres() -> psycopg.Connection:
    """Create a PostgreSQL connection using the source-system environment."""
    return psycopg.connect(
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=os.getenv("POSTGRES_PORT", "5432"),
        dbname=os.getenv("POSTGRES_DB", "olist"),
        user=os.getenv("POSTGRES_USER", "olist_user"),
        password=os.getenv("POSTGRES_PASSWORD", "olist_pass"),
    )


def export_table_to_s3(
    conn: psycopg.Connection,
    s3_client,
    table_name: str,
    bucket: str,
    raw_prefix: str = "raw/olist",
) -> int:
    """Export one PostgreSQL table as CSV to its S3 historical prefix.

    Returns the source row count.
    """
    if table_name not in HISTORICAL_TABLES:
        raise ValueError(f"Unsupported historical table: {table_name}")

    count_sql = f"SELECT COUNT(*) FROM olist.{table_name}"
    copy_sql = (
        f"COPY (SELECT * FROM olist.{table_name}) "
        "TO STDOUT WITH (FORMAT CSV, HEADER TRUE)"
    )

    s3_key = f"{raw_prefix.rstrip('/')}/{table_name}/historical/{table_name}.csv"

    with conn.cursor() as cur:
        cur.execute(count_sql)
        row_count = cur.fetchone()[0]

    with tempfile.TemporaryDirectory() as temp_dir:
        local_path = Path(temp_dir) / f"{table_name}.csv"

        with conn.cursor() as cur:
            with cur.copy(copy_sql) as copy:
                with local_path.open("wb") as output:
                    while data := copy.read():
                        output.write(data)

        s3_client.upload_file(str(local_path), bucket, s3_key)

    print(
        f"{table_name:<24} "
        f"{row_count:>10,} rows  ->  s3://{bucket}/{s3_key}"
    )

    return row_count


def load_historical(
    bucket: str,
    tables: Iterable[str] = HISTORICAL_TABLES,
    raw_prefix: str = "raw/olist",
) -> None:
    """Load the initial PostgreSQL snapshot into S3 historical/ prefixes."""
    s3_client = boto3.client("s3")

    print("Starting PostgreSQL historical load...")
    print()

    with connect_to_postgres() as conn:
        for table_name in tables:
            export_table_to_s3(
                conn=conn,
                s3_client=s3_client,
                table_name=table_name,
                bucket=bucket,
                raw_prefix=raw_prefix,
            )

    print()
    print("Historical load completed successfully.")
