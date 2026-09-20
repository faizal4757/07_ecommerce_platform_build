# Authentication is supplied by Databricks unified authentication, using the
# local, ignored DATABRICKS_HOST and DATABRICKS_TOKEN environment variables.
# Do not add credentials to this file.

provider "databricks" {
  profile = "default"
}

provider "aws" {
  region = "us-east-1"
}