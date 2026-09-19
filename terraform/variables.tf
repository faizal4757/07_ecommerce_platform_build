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

variable "airbyte_username" {
  description = "Airbyte local instance username."
  type        = string
  sensitive   = true
}

variable "airbyte_password" {
  description = "Airbyte local instance password."
  type        = string
  sensitive   = true
}

variable "airbyte_client_id" {
  type      = string
  sensitive = true
}

variable "airbyte_client_secret" {
  type      = string
  sensitive = true
}

variable "airbyte_workspace_id" {
  description = "Airbyte workspace ID."
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "Password for the Olist PostgreSQL user."
  type        = string
  sensitive   = true
}

variable "aws_access_key_id" {
  description = "AWS access key ID for Airbyte to write to S3."
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key for Airbyte to write to S3."
  type        = string
  sensitive   = true
}