resource "aws_iam_role" "databricks_olist_access" {
  name = "databricks-olist-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          AWS = [
            "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL",
            "arn:aws:iam::702127848749:role/databricks-olist-access"
          ]
        }

        Action = "sts:AssumeRole"

        Condition = {
          StringEquals = {
            "sts:ExternalId" = "a9563243-0e5c-404b-9dbb-db588d9a03e2"
          }
        }
      }
    ]
  })

  tags = {
    Project     = "Olist Data Platform"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "Databricks Unity Catalog S3 Access"
  }
}

resource "aws_iam_role_policy" "databricks_olist_s3" {
  name = "databricks-olist-s3-access"

  role = aws_iam_role.databricks_olist_access.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "s3:*"

        Resource = [
          aws_s3_bucket.olist_data.arn,
          "${aws_s3_bucket.olist_data.arn}/*"
        ]
      },
      {
        Effect = "Allow"

        Action = "sts:AssumeRole"

        Resource = aws_iam_role.databricks_olist_access.arn
      }
    ]
  })
}