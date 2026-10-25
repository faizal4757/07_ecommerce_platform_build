# Olist dbt transformations

This is a standalone dbt Core project for transforming the existing Databricks Unity Catalog Bronze tables into Silver and Gold.

## Tooling

Use a dedicated local virtual environment for dbt CLI dependencies. Do not add dbt dependencies to the ingestion wheel in the repository-root `pyproject.toml`.

Pin the exact `dbt-core` and `dbt-databricks` versions in the local constraints/requirements file once the supported pair is verified for the project environment. Credentials belong in an untracked local `profiles.yml` or an approved service-principal environment configuration, never in Git.

## Current scope

- `models/staging/olist`: source-shaped views over Bronze.
- `models/intermediate`: conformed Silver tables.
- `models/marts`: contracted Gold models.

The initial source declarations intentionally do not configure freshness. Freshness requires a verified, reliable ingestion timestamp column; do not guess a timestamp field from business timestamps such as order purchase time.

## First validation

From the repository root, after local tooling and profile are configured:

```powershell
dbt --version
dbt deps --project-dir .\dbt
dbt debug --project-dir .\dbt --target dev
dbt parse --project-dir .\dbt --target dev
```

Before running models, compare the model select lists with actual Bronze table schemas. If the ingest has retained metadata columns, configure freshness against the actual ingestion timestamp contract.
