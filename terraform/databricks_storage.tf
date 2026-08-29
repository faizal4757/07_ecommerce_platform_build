resource "databricks_storage_credential" "olist_s3" {
  name = "olist-s3-storage-credential"

  aws_iam_role {
    role_arn = aws_iam_role.databricks_olist_access.arn
  }

  comment = "Storage credential for Olist S3 data platform managed by Terraform"


}