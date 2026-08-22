resource "databricks_catalog" "ecommerce_dev" {
  name         = "ecommerce_dev"
  storage_root = "s3://ecommerce-pipeline-faizal-dev/catalogue/ecommerce_dev"
  comment      = "Development catalog managed by Terraform"

  properties = {
    environment = "dev"
    project     = "ecommerce"
    managed_by  = "terraform"
  }
}


resource "databricks_catalog" "ecommerce_stg" {
  name         = "ecommerce_dev"
  storage_root = "s3://ecommerce-pipeline-faizal-dev/catalogue/ecommerce_stg"
  comment      = "Development catalog managed by Terraform"

  properties = {
    environment = "stg"
    project     = "ecommerce"
    managed_by  = "terraform"
  }
}


resource "databricks_catalog" "ecommerce_prod" {
  name         = "ecommerce"
  storage_root = "s3://ecommerce-pipeline-faizal-dev/catalogue/ecommerce_prod"
  comment      = "Managed by Terraform"

  properties = {
    environment = "prod"
    managed_by  = "terraform"
    project     = "ecommerce"
  }
}

