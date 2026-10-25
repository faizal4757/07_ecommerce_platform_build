# Olist dbt transformations

Standalone dbt Core project for transforming existing Databricks Unity Catalog Bronze tables into Silver and Gold. The root `pyproject.toml` remains dedicated to the existing ingestion wheel.

## Pinned tooling

- `dbt-core==1.12.0`
- `dbt-databricks==1.12.4`

This pair is from the August 2026 dbt v1 compatible release track. Keep the dbt CLI environment separate from the ingestion runtime.

## Local Windows setup

From the repository root, create a dedicated virtual environment and install the pinned tooling:

```powershell
py -3.11 -m venv .venv-dbt
.\.venv-dbt\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r .\dbt\requirements-dbt.txt
dbt --version
```

Copy the example profile to the standard dbt profile directory. Do not put the token in the repository:

```powershell
New-Item -ItemType Directory -Force "$HOME\.dbt" | Out-Null
Copy-Item .\dbt\profiles.example.yml "$HOME\.dbt\profiles.yml"
```

Set workspace credentials in the current PowerShell session. Obtain the workspace host from your Databricks profile and the HTTP Path from the SQL Warehouse connection details. Do not print or commit tokens.

```powershell
$env:DATABRICKS_HOST = "https://<workspace-host>"
$env:DATABRICKS_TOKEN = "<short-lived-personal-token>"
$env:DBT_DATABRICKS_HTTP_PATH = "/sql/1.0/warehouses/<warehouse-id>"
```

The values in angle brackets above must be replaced locally. For team CI/prod, use a service principal with OAuth and least-privilege Unity Catalog grants rather than a human PAT.

## Resolve and verify packages

```powershell
dbt deps --project-dir .\dbt
dbt debug --project-dir .\dbt --target dev
dbt parse --project-dir .\dbt --target dev
```

Commit the generated `dbt/package-lock.yml` after successful dependency resolution.

## Current scope and data contract

- `models/staging/olist`: source-shaped views over Bronze.
- `models/intermediate`: conformed Silver tables.
- `models/marts`: contracted Gold models.

Source declarations point to `01_ecommerce_dev.bronze`. The initial project targets `dbt_dev` for model output, so it does not write into the existing Bronze schema. The development identity needs `USE CATALOG`, `USE SCHEMA`, source `SELECT`, and target `CREATE VIEW`/ `CREATE TABLE` grants as applicable.

Source freshness is not configured until a reliable ingestion timestamp is verified in the table schema. Business timestamps, such as order purchase time, are not ingestion timestamps.

Before executing the staging models, compare their select lists with the actual Bronze schemas using a Databricks SQL query or `DESCRIBE TABLE`. Then run a scoped build and tests. Do not full-refresh upstream Bronze data from dbt.
