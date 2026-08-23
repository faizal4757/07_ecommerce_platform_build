resource "databricks_external_location" "olist_raw" {
  name = "olist-raw"

  url = "s3://${aws_s3_bucket.olist_data.bucket}/raw/"

  credential_name = databricks_storage_credential.olist_s3.name

  comment = "Raw Olist data landing location managed by Terraform"
}