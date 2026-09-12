# AGENTS.md — AI Agent Operating Guide

This document is the primary operating reference for AI coding agents working in this repository. Treat it as an engineering contract.

## Repository Purpose

This repository implements the **Olist Data Platform** — an ecommerce analytics platform that ingests raw transactional data from Amazon S3, processes it through a medallion lakehouse architecture on Databricks, and produces governed datasets for analytics.

## System Boundaries

| Boundary | Owner |
|---|---|
| AWS infrastructure (S3, IAM) | Terraform (`terraform/`) |
| Databricks Unity Catalog (catalogs, schemas, credentials, locations) | Terraform (`terraform/`) |
| Data processing logic | Python (`src/`) |
| Job definitions and deployment | Databricks Asset Bundles (`databricks.yml`, `resources/`) |
| Package build | `pyproject.toml` + setuptools |

## Architecture Overview

```text
AWS S3 (raw data) → Auto Loader → Bronze (Delta) → Silver → Gold → Analytics
```

Access chain: **Databricks Job → Unity Catalog External Location → Storage Credential → IAM Role → S3**

Three environment catalogs (`01_ecommerce_dev`, `02_ecommerce_stg`, `03_ecommerce_prod`), each with `bronze`, `silver`, `gold` schemas.

## Directory Responsibilities

| Directory | Purpose | Modify When |
|---|---|---|
| `terraform/` | AWS and Databricks infrastructure as code | Adding/changing cloud resources or governance |
| `src/ingestion/` | Reusable data processing modules | Adding/modifying ingestion logic |
| `src/jobs/` | Databricks job entry points (thin CLI wrappers) | Adding new jobs or changing job arguments |
| `resources/` | Databricks Asset Bundle job definitions (YAML) | Adding/changing job configuration, parameters, or schedules |
| `data/raw/` | Local sample data (gitignored) | Never — not committed to version control |
| `tests/` | Automated tests | Adding/modifying tests |
| `docs/` | Platform documentation | When architecture, operations, or conventions change |

## Source of Truth Rules

| Subject | Source of Truth |
|---|---|
| Infrastructure state | Terraform configuration in `terraform/` |
| Resource inventory | `terraform/terraform.tfstate` (local, gitignored) |
| Platform architecture | `docs/architecture.md` |
| Security model | `docs/security.md` |
| Deployment model | `docs/deployment.md` |
| Terraform operations | `docs/terraform.md` |
| AI agent instructions | This file (`AGENTS.md`) |
| Contribution workflow | `CONTRIBUTING.md` |

## Python Package Structure

```text
src/
├── ingestion/           Reusable modules (importable, no CLI logic)
│   ├── __init__.py
│   └── ingestion.py     ingest_to_bronze() function
└── jobs/
    └── bronze_ingestion.py   Entry point (argparse wrapper → calls ingestion module)
```

**Convention**: Reusable application logic lives in packages under `src/` (e.g., `src/ingestion/`). Job entry points under `src/jobs/` are thin wrappers that parse arguments and invoke reusable modules.

**Package definition**: `pyproject.toml` (setuptools backend, `src/` layout).

**Build**: `python -m build` produces a wheel in `dist/`.

## Databricks Asset Bundle Conventions

- **Bundle config**: `databricks.yml` (root)
- **Job definitions**: `resources/*.yml` (included via `resources/*.yml` glob)
- **Artifacts**: Wheel built from `pyproject.toml` via `python -m build`
- **Targets**: `dev` (default, development mode)
- **Environment**: Serverless (environment version `5`)

### Adding a New Job

1. Create a reusable module under `src/<module_name>/` with `__init__.py`.
2. Create a thin entry point under `src/jobs/<job_name>.py`.
3. Create a job definition under `resources/<job_name>.yml`.
4. Reference the wheel library in the job task: `libraries: [{whl: ../dist/*.whl}]`.
5. Run `databricks bundle validate` to verify.

## Infrastructure Conventions

- Terraform configuration is **root-level** — do not introduce modules.
- Terraform version: `>= 1.15.0, < 2.0.0`.
- Providers: `databricks/databricks ~> 1.0`, `hashicorp/aws ~> 6.0`.
- AWS region: `us-east-1`.
- Always run `terraform fmt` → `validate` → `plan` → review before applying.

## Unity Catalog and Data Governance

- Three catalogs: `01_ecommerce_dev`, `02_ecommerce_stg`, `03_ecommerce_prod`.
- Each catalog has `bronze`, `silver`, `gold` schemas.
- All data access must flow through Unity Catalog external locations.
- Do not bypass Unity Catalog governance with direct S3 access.
- Storage credential: `olist-s3-storage-credential` (backed by IAM role).
- External locations: `olist-raw` (raw data), `olist-databricks-managed` (catalog storage).

## Security Constraints

1. **Never commit credentials, secrets, tokens, or API keys** to the repository.
2. `.env`, `*.tfstate`, `*.tfvars`, `secrets/`, `.terraform/`, `data/` are gitignored.
3. Do not hardcode AWS account IDs, ARNs, or bucket names outside of `terraform/variables.tf`.
4. Do not weaken S3 security (public access blocking, encryption, versioning).
5. Do not bypass Unity Catalog governance.
6. IAM policy currently uses `s3:*` (known issue, planned for narrowing) — do not expand scope.
7. Do not expose Terraform state or its contents.

## Testing Expectations

- `tests/` directory exists but is currently empty.
- When adding new Python modules, add corresponding tests.
- **Planned**: `pytest` test suite for ingestion logic and utility functions.

## Validation Requirements

| Change Type | Required Validation |
|---|---|
| Terraform | `terraform fmt -check`, `terraform validate`, `terraform plan` |
| Databricks bundle | `databricks bundle validate` |
| Python code | `pytest` (when tests exist) |
| Any change | Verify no secrets in staged files (`git diff --staged`) |

## Deployment Conventions

- Deploy via Databricks Asset Bundles: `databricks bundle deploy`.
- Run jobs: `databricks bundle run <job_name>`.
- Always validate before deploying: `databricks bundle validate`.
- Build artifacts are gitignored (`dist/`, `build/`, `*.whl`).

## Change Management Rules

1. **Inspect before modifying.** Read existing code, configuration, and documentation before making changes.
2. **Prefer extending existing abstractions.** Do not duplicate logic that already exists in `src/ingestion/` or other modules.
3. **Do not introduce a second implementation** of an existing capability without explicit justification.
4. **Keep job entry points thin.** CLI parsing and lifecycle management only — no business logic in `src/jobs/`.
5. **Do not introduce Terraform modules.** The root-level layout is intentional.
6. **Do not add dependencies** to `pyproject.toml` without justification. PySpark and Delta Lake are provided by the Databricks runtime.
7. **Preserve security boundaries.** Do not weaken IAM policies, remove S3 protections, or bypass Unity Catalog.
8. **Update documentation** when architecture, operations, or conventions change.
9. **Do not modify generated artifacts** (`dist/`, `build/`, `.terraform/`, `.databricks/`) manually.
10. **Do not commit secrets** under any circumstances.
11. **Do not silently change data contracts** (table schemas, column names, data types) without documenting the change.

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| S3 buckets | `olist-data-platform-<purpose>` | `olist-data-platform-raw` |
| IAM roles | `databricks-olist-<purpose>` | `databricks-olist-access` |
| Catalogs | `##_ecommerce_<env>` | `01_ecommerce_dev` |
| Schemas | Medallion layer name | `bronze`, `silver`, `gold` |
| Storage credentials | `olist-<purpose>-credential` | `olist-s3-storage-credential` |
| External locations | `olist-<purpose>` | `olist-raw` |
| DAB jobs | `olist-<layer>-<operation>` | `olist-bronze-ingestion` |
| Python packages | Lowercase with underscores | `ingestion` |
| Job entry points | `<layer>_<operation>.py` | `bronze_ingestion.py` |

## Pre-Change Inspection Requirements

Before modifying any file, inspect:

1. The file being changed and its surrounding context.
2. Related configuration files that may reference the file.
3. `docs/architecture.md` for the current implementation status.
4. `AGENTS.md` (this file) for relevant conventions and constraints.
5. `.gitignore` to understand what is and is not committed.

## Post-Change Verification Requirements

After making changes, verify:

1. No secrets or credentials are in staged files.
2. Terraform changes pass `terraform fmt -check` and `terraform validate`.
3. DAB changes pass `databricks bundle validate`.
4. Python changes pass tests (when tests exist).
5. Documentation is updated if architecture or operations changed.
6. Naming conventions are followed.
7. No gitignored files are accidentally staged.

## What Not To Do

- Do not frame documentation or code comments as a learning exercise or tutorial.
- Do not fabricate successful test or deployment results.
- Do not present planned features as current implementation.
- Do not invent infrastructure resources that do not exist in Terraform configuration.
- Do not introduce Airflow, Docker, dbt, or other technologies without explicit architectural approval — placeholder files exist (`Dockerfile`, `docker-compose.yml`, `requirements-airflow.txt`) but contain no implementation.
