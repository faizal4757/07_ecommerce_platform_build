# =============================================================================
# airbyte.tf
# Olist E-Commerce Data Platform
#
# Provisions:
#   1. PostgreSQL Source  (Docker → host.docker.internal, CDC via WAL)
#   2. S3 Destination    (→ olist-data-platform-raw)
#   3. Connection        (initial snapshot → CDC incremental)
# =============================================================================

locals {
  olist_tables = [
    "customers",
    "orders",
    "order_items",
    "order_payments",
    "order_reviews",
    "products",
    "sellers",
    "geolocation",
    "category_translation",
  ]

  airbyte_s3_prefix = "raw/airbyte"
}

resource "airbyte_source" "postgres" {
  name         = "olist-postgres-source"
  workspace_id = var.airbyte_workspace_id

  configuration = jsonencode({
    sourceType = "postgres"

    host     = "host.docker.internal"
    port     = 5432
    database = "olist"
    username = "olist_user"
    password = var.postgres_password
    schemas  = ["olist"]

    ssl_mode = {
      mode = "disable"
    }

    tunnel_method = {
      tunnel_method = "NO_TUNNEL"
    }

    replication_method = {
      method                  = "CDC"
      replication_slot        = "airbyte_slot"
      publication             = "airbyte_publication"
      initial_waiting_seconds = 300
    }
  })
}

resource "airbyte_destination" "s3" {
  name         = "olist-s3-raw-destination"
  workspace_id = var.airbyte_workspace_id

  configuration = jsonencode({
    destinationType = "s3"

    s3_bucket_name   = var.raw_bucket_name
    s3_bucket_path   = local.airbyte_s3_prefix
    s3_bucket_region = "eu-central-1"

    access_key_id     = var.aws_access_key_id
    secret_access_key = var.aws_secret_access_key

    format = {
      format_type       = "JSONL"
      compression_codec = "GZIP"
    }
  })
}

resource "airbyte_connection" "postgres_to_s3" {
  name           = "olist-postgres-to-s3"
  source_id      = airbyte_source.postgres.source_id
  destination_id = airbyte_destination.s3.destination_id

  schedule = {
    schedule_type   = "cron"
    cron_expression = "0 */6 * * *"
  }

  depends_on = [
    airbyte_source.postgres,
    airbyte_destination.s3,
  ]
}

output "airbyte_source_id" {
  description = "Airbyte PostgreSQL source ID"
  value       = airbyte_source.postgres.source_id
}

output "airbyte_destination_id" {
  description = "Airbyte S3 destination ID"
  value       = airbyte_destination.s3.destination_id
}

output "airbyte_connection_id" {
  description = "Airbyte connection ID (Postgres → S3)"
  value       = airbyte_connection.postgres_to_s3.connection_id
}

output "airbyte_s3_landing_path" {
  description = "S3 path where Airbyte lands raw files"
  value       = "s3://${var.raw_bucket_name}/${local.airbyte_s3_prefix}/"
}