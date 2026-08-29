# Ecommerce Data Platform

> A hands-on learning project that applies production-minded engineering
> practices while building one coherent ecommerce data platform.

## Architecture

```text
AWS S3 raw data -> Databricks Bronze -> Silver -> Gold -> Analytics / BI
```

Terraform currently manages the AWS and Databricks governance foundation.
PySpark ingestion, Delta tables, dbt transformations, jobs, and BI are planned
later stages.

## Current status

Checkpoint 4, **Governed S3 Access**, is in progress. Terraform has created two
protected S3 buckets, the Databricks IAM role and storage credential, and two
Unity Catalog external locations. Unity Catalog grants and an end-to-end
Databricks-to-S3 access validation remain before any Olist data is loaded.

See the [project journal](docs/project.md) for the authoritative checkpoint and
roadmap, and the [Terraform guide](docs/terraform.md) for infrastructure
details.

## Repository layout

```text
terraform/       AWS and Databricks infrastructure as code
src/             Future ingestion and processing code
notebooks/       Exploratory and learning notebooks
data/            Local sample data only; ignored by Git
tests/           Automated tests
docs/            Architecture, checkpoint journal, and operating guides
```

## Local setup

1. Put local Databricks credentials in the ignored `.env` file:

   ```dotenv
   DATABRICKS_HOST=https://<your-workspace-url>
   DATABRICKS_TOKEN=<your-personal-access-token>
   ```

2. Load those variables into your shell without committing them.
3. From `terraform/`, run `terraform init`, `terraform fmt`,
   `terraform validate`, and `terraform plan`.

Do not put secrets, Terraform state, generated files, or Olist source data in
Git.

## Contribution workflow

Develop each checkpoint on a focused branch, validate it, and submit it as a
pull request. The project owner reviews and merges changes; `main` is not a
direct development branch. See [CONTRIBUTING.md](CONTRIBUTING.md).
