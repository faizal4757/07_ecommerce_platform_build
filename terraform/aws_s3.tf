resource "aws_s3_bucket" "olist_data" {
  bucket = "olist-data-platform-faizal"
  tags = {
    Project     = "Olist Data Platform"
    Environment = "dev"
    ManagedBy   = "Terraform"
    DataDomain  = "Ecommerce"
  }
}

resource "aws_s3_bucket_public_access_block" "olist_data" {
  bucket = aws_s3_bucket.olist_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "olist_data" {
  bucket = aws_s3_bucket.olist_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "olist_data" {
  bucket = aws_s3_bucket.olist_data.id

  versioning_configuration {
    status = "Enabled"
  }
}
