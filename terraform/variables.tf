variable "aws_account_id" {
  description = "AWS account ID used by this learning project."
  type        = string
  default     = "702127848749"
}

variable "olist_bucket_name" {
  description = "S3 bucket used by the Olist data platform."
  type        = string
  default     = "olist-data-platform-faizal"
}