resource "databricks_external_location" "olist_raw" {
  name = "olist-raw"

  url = "s3://${aws_s3_bucket.raw_data.bucket}/raw/"

  credential_name = databricks_storage_credential.olist_s3.name

  comment = "Raw Olist data landing location managed by Terraform"
}

resource "databricks_external_location" "databricks_managed" {
  name = "olist-databricks-managed"

  url = "s3://${aws_s3_bucket.databricks_data.bucket}/catalogue/"

  credential_name = databricks_storage_credential.olist_s3.name

  comment = "Databricks managed storage location for Olist catalogs"
}