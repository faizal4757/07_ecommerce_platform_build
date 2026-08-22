locals {
  schemas = {
    dev_bronze = {
      catalog = databricks_catalog.catalog_01_ecommerce_dev.name
      schema  = "bronze"
    }

    dev_silver = {
      catalog = databricks_catalog.catalog_01_ecommerce_dev.name
      schema  = "silver"
    }

    dev_gold = {
      catalog = databricks_catalog.catalog_01_ecommerce_dev.name
      schema  = "gold"
    }

    stg_bronze = {
      catalog = databricks_catalog.catalog_02_ecommerce_stg.name
      schema  = "bronze"
    }

    stg_silver = {
      catalog = databricks_catalog.catalog_02_ecommerce_stg.name
      schema  = "silver"
    }

    stg_gold = {
      catalog = databricks_catalog.catalog_02_ecommerce_stg.name
      schema  = "gold"
    }

    prod_bronze = {
      catalog = databricks_catalog.catalog_03_ecommerce_prod.name
      schema  = "bronze"
    }

    prod_silver = {
      catalog = databricks_catalog.catalog_03_ecommerce_prod.name
      schema  = "silver"
    }

    prod_gold = {
      catalog = databricks_catalog.catalog_03_ecommerce_prod.name
      schema  = "gold"
    }
  }
}

resource "databricks_schema" "medallion" {
  for_each = local.schemas

  name         = each.value.schema
  catalog_name = each.value.catalog
}