# Ecommerce Data Platform

> **Learning project with production-grade engineering practices.** This
> repository is a hands-on implementation of an ecommerce data platform. It is
> intentionally built incrementally to make each architectural decision
> understandable, while using the review, security, and deployment conventions
> expected of a production data platform.

## Architecture

```text
AWS S3 raw data -> Databricks Bronze -> Silver -> Gold -> Analytics / BI
```

Terraform manages Databricks and Unity Catalog infrastructure. PySpark handles
ingestion, dbt handles transformations, and Databricks Asset Bundles will
package Databricks jobs and related assets.

## Current status

Checkpoint 2 is in progress: the Terraform project and Databricks provider are
initialized and validated before any Unity Catalog resources are managed as
code. The authenticated workspace connectivity test remains pending. See [the
project journal](docs/project.md) for the authoritative current state and [the
Terraform guide](docs/terraform.md) for setup details.

## Engineering principles

- Keep credentials, Terraform state, and generated files out of version control.
- Make infrastructure changes declarative, reviewable, and reproducible.
- Distinguish the current environment from the intended architecture.
- Validate changes before deployment and document decisions as they are made.
- Use pull requests for every completed learning checkpoint.

## Repository layout

```text
terraform/       Databricks and Unity Catalog infrastructure as code
src/             Ingestion and processing code
notebooks/       Exploratory and learning notebooks
data/            Local sample data only; source data remains in S3
tests/           Automated tests
docs/            Architecture, checkpoint journal, and operating guides
```

## Local setup

1. Copy the required local credentials into the ignored `.env` file:

   ```dotenv
   DATABRICKS_HOST=https://<your-workspace-url>
   DATABRICKS_TOKEN=<your-personal-access-token>
   ```

2. Load these variables into your shell without committing them.
3. From `terraform/`, run `terraform init` and `terraform validate`.

Do not place secrets in `.tf`, `.tfvars`, Markdown, commits, or pull requests.

## Contribution workflow

Each checkpoint is developed on a focused branch and delivered as one commit.
The branch is pushed for a user-created pull request; `main` changes only after
that PR is reviewed and merged. See [CONTRIBUTING.md](CONTRIBUTING.md).
