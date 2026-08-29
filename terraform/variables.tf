variable "aws_account_id" {
  description = "AWS account ID used by this  project."
  type        = string
  default     = "702127848749"
}

variable "raw_bucket_name" {
  description = "S3 bucket containing raw Olist source data."
  type        = string
  default     = "olist-data-platform-raw"
}

variable "databricks_bucket_name" {
  description = "S3 bucket used for Databricks-managed storage."
  type        = string
  default     = "olist-data-platform-databricks"
}