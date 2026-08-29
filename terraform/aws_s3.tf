resource "aws_s3_bucket" "raw_data" {
  bucket = var.raw_bucket_name

  tags = {
    Project    = "Olist Data Platform"
    ManagedBy  = "Terraform"
    DataDomain = "Ecommerce"
    Purpose    = "Raw Source Data"
  }
}

resource "aws_s3_bucket_public_access_block" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket" "databricks_data" {
  bucket = var.databricks_bucket_name

  tags = {
    Project    = "Olist Data Platform"
    ManagedBy  = "Terraform"
    DataDomain = "Ecommerce"
    Purpose    = "Databricks Managed Storage"
  }
}

resource "aws_s3_bucket_public_access_block" "databricks_data" {
  bucket = aws_s3_bucket.databricks_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "databricks_data" {
  bucket = aws_s3_bucket.databricks_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "databricks_data" {
  bucket = aws_s3_bucket.databricks_data.id

  versioning_configuration {
    status = "Enabled"
  }
}