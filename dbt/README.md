# Olist dbt transformations

Standalone dbt Core project for transforming existing Databricks Unity Catalog Bronze tables into Silver and Gold. The root `pyproject.toml` remains dedicated to the existing ingestion wheel.

## Pinned tooling

- `dbt-core==1.12.0`
- `dbt-databricks==1.12.4`

This pair is from the August 2026 dbt v1 compatible release track. Keep the dbt CLI environment separate from the ingestion runtime.

## Local Windows setup

Use the existing `.venv-dbt` environment (Python 3.14.7) and pinned dbt packages. Keep it separate from the ingestion environment:

```powershell
.\.venv-dbt\Scripts\Activate.ps1
dbt --version
```

Keep the local profile in the ignored dbt project directory:

```powershell
Copy-Item .\dbt\profiles.example.yml .\dbt\profiles.yml
```

Authenticate the Databricks CLI with OAuth once (`databricks auth login --host <workspace-url> --profile dev`) if needed. Set connection values for the current PowerShell session. The CLI command below places its short-lived OAuth access token directly into the environment; do not print or commit it.

```powershell
$env:DBT_DATABRICKS_HOST = (databricks auth describe --profile dev -o json | ConvertFrom-Json).details.host
$env:DBT_DATABRICKS_HTTP_PATH = "/sql/1.0/warehouses/<warehouse-id>"
$env:DATABRICKS_TOKEN = (databricks auth token dev -o json | ConvertFrom-Json).access_token
```

Replace the HTTP Path placeholder with the value from the Databricks SQL Warehouse connection details. For team CI/prod, use a service principal with OAuth and least-privilege Unity Catalog grants.

The configured SQL warehouse must be running for `dbt debug` and SQL queries. `dbt parse` is offline and does not create relations.

## Resolve and verify packages

```powershell
dbt deps --project-dir .\dbt --profiles-dir .\dbt
dbt debug --project-dir .\dbt --profiles-dir .\dbt --target dev
dbt parse --project-dir .\dbt --profiles-dir .\dbt --target dev
```

Review and commit `dbt/package-lock.yml` when dependency versions change.

## Current scope and data contract

- `models/staging/olist`: source-shaped views over Bronze.
- `models/intermediate`: conformed Silver tables.
- `models/marts`: contracted Gold models.

Source declarations point to `01_ecommerce_dev.bronze`. Development models target `01_ecommerce_dev.dbt_staging`, `01_ecommerce_dev.silver`, and `01_ecommerce_dev.gold`; the custom schema macro uses those names directly, avoiding dbt's default target-schema prefixing. These output schemas must remain separate from `bronze`. The development identity needs `USE CATALOG`, `USE SCHEMA`, source `SELECT`, and target `CREATE VIEW`/`CREATE TABLE` grants as applicable.

Source freshness is not configured until a reliable ingestion timestamp is verified in the table schema. Business timestamps, such as order purchase time, are not ingestion timestamps.

Before executing the staging models, compare their select lists with the actual Bronze schemas using a Databricks SQL query or `DESCRIBE TABLE`. Then run a scoped build and tests. Do not full-refresh upstream Bronze data from dbt.
