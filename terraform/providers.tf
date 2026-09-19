# Authentication is supplied by Databricks unified authentication, using the
# local, ignored DATABRICKS_HOST and DATABRICKS_TOKEN environment variables.
# Do not add credentials to this file.

provider "databricks" {
  profile = "default"
}

provider "aws" {
  region = "us-east-1"
}

provider "airbyte" {
  server_url    = "http://localhost:8000"
  client_id     = var.airbyte_client_id
  client_secret = var.airbyte_client_secret
  token_url     = "http://localhost:8000/api/v1/applications/token"
}