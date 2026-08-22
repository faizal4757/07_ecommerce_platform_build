resource "databricks_catalog" "catalog_01_ecommerce_dev" {
  name         = "01_ecommerce_dev"
  storage_root = "s3://ecommerce-pipeline-faizal-dev/catalogue/01_ecommerce_dev"
  comment      = "Development catalog managed by Terraform"

  properties = {
    environment = "dev"
    project     = "ecommerce"
    managed_by  = "terraform"
  }
}

resource "databricks_catalog" "catalog_02_ecommerce_stg" {
  name         = "02_ecommerce_stg"
  storage_root = "s3://ecommerce-pipeline-faizal-dev/catalogue/02_ecommerce_stg"
  comment      = "Staging catalog managed by Terraform"

  properties = {
    environment = "stg"
    project     = "ecommerce"
    managed_by  = "terraform"
  }
}

resource "databricks_catalog" "catalog_03_ecommerce_prod" {
  name         = "03_ecommerce_prod"
  storage_root = "s3://ecommerce-pipeline-faizal-dev/catalogue/03_ecommerce_prod"
  comment      = "Production catalog managed by Terraform"

  properties = {
    environment = "prod"
    project     = "ecommerce"
    managed_by  = "terraform"
  }
}