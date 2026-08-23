# Ecommerce Data Platform

> **Hands-on learning project with production discipline.** This repository
> progressively builds one coherent ecommerce data platform while practicing the
> engineering standards used in production: infrastructure as code, secure
> configuration, validation, feature branches, pull requests, and documented
> architecture decisions.

## 1. Project overview

The project is an AWS and Databricks ecommerce data platform. Its common domain
is the **Olist Brazilian E-Commerce dataset**. The goal is not to assemble
disconnected tutorials: every skill is learned by evolving the same platform.

## 2. Project objective

Build a governed pipeline that will ingest Olist raw data from Amazon S3 into
Databricks, process it through bronze, silver, and gold layers, and make it
available for analytics. Infrastructure and governance are established before
data ingestion.

## 3. Current status

**Checkpoint:** 4 — Governed S3 Access

**Current state:** Checkpoints 1 through 4A are complete. Terraform manages the
current AWS and Databricks infrastructure. Checkpoint 4B, S3 security
configuration, is the next implementation task.

**Important:** The Olist data has not been downloaded or uploaded. No ingestion
pipeline, Delta table, dbt model, Databricks job, or CI/CD pipeline exists yet.

## 4. Completed checkpoints

| Checkpoint | Status | Evidence |
| --- | --- | --- |
| 1. Terraform setup | Completed | Terraform 1.15.9 is installed and available on the local PATH. |
| 2. Databricks catalogs | Completed | Terraform manages development, staging, and production Unity Catalog catalogs. |
| 3. Medallion schemas | Completed | Terraform manages bronze, silver, and gold schemas in every catalog. |
| 4A. S3 foundation | Completed | Terraform manages the dedicated, currently empty Olist S3 bucket. |

## 5. Current checkpoint: Governed S3 Access

Checkpoint 4 establishes safe, governed access between AWS S3 and Databricks.

| Stage | Status | Scope |
| --- | --- | --- |
| 4A | Completed | AWS provider and dedicated Olist S3 bucket. |
| 4B | Planned — next | S3 public-access blocking, encryption, versioning, and tags. |
| 4C | Planned | IAM roles, trust policies, and least-privilege permissions. |
| 4D | Planned | Unity Catalog storage credential. |
| 4E | Planned | Unity Catalog external location. |
| 4F | Planned | Least-privilege Unity Catalog grants. |
| 4G | Planned | Validate governed Databricks-to-S3 access. |

Only after 4G is complete should the project acquire Olist data, upload it to
the governed raw-data location, and begin ingestion.

## 6. Current Terraform architecture

The Terraform configuration is intentionally simple and root-level. Do not add
modules or refactor this layout during the current learning stage. An earlier
Databricks module experiment was abandoned and is not current architecture.

```text
terraform/
├── .terraform/                 Local provider cache (ignored)
├── .terraform.lock.hcl         Committed provider dependency lock
├── aws_s3.tf                   Olist S3 bucket
├── catalog.tf                  Databricks catalogs
├── providers.tf                AWS and Databricks provider configuration
├── schemas.tf                  Medallion schemas
├── versions.tf                 Terraform and provider constraints
└── local Terraform state files (ignored)
```

Terraform requires version `>= 1.15.0, < 2.0.0`. The Databricks provider is
constrained to `~> 1.0`, and the AWS provider to `~> 6.0`. The AWS region is
`us-east-1`. Databricks credentials are supplied locally through unified
authentication; secrets never belong in Terraform source files.

## 7. Current infrastructure inventory

Terraform local state contains **13 managed resources**.

| Platform | Resources | Current state |
| --- | --- | --- |
| AWS | `aws_s3_bucket.olist_data` | Bucket `olist-data-platform-faizal`; empty; no Olist data loaded. |
| Databricks | 3 catalogs | `01_ecommerce_dev`, `02_ecommerce_stg`, `03_ecommerce_prod`. |
| Databricks | 9 schemas | Bronze, silver, and gold schemas in each environment catalog. |

The catalog managed-storage roots are currently:

```text
s3://ecommerce-pipeline-faizal-dev/catalogue/01_ecommerce_dev
s3://ecommerce-pipeline-faizal-dev/catalogue/02_ecommerce_stg
s3://ecommerce-pipeline-faizal-dev/catalogue/03_ecommerce_prod
```

The environment-first namespace keeps development and staging workloads
separate from production. The medallion layer is represented by schemas, for
example `01_ecommerce_dev.bronze` and `03_ecommerce_prod.gold`.

## 8. Immediate next steps

1. Configure S3 public-access blocking.
2. Enable S3 server-side encryption.
3. Enable S3 versioning.
4. Add consistent S3 tags.
5. Run `terraform fmt`, `terraform validate`, and `terraform plan` before a
   pull request.

## 9. Olist dataset and domain

The Olist Brazilian E-Commerce dataset is the planned source domain. It will
provide the ecommerce entities needed for later ingestion, transformations, and
analytics. Its acquisition and upload are deliberately deferred until S3 and
Databricks access are governed.

## 10. Target architecture

This is the **target architecture**, not the current implementation.

```text
Git / GitHub
    |
Feature branches and pull requests
    |
CI/CD
    |
Terraform
   / \
 AWS   Databricks
  |       |
 S3   Unity Catalog
  |       |
  |   Storage credential
  |       |
  |   External location
  |       |
  +-------+
      |
  Olist raw data
      |
  Batch / streaming ingestion
      |
    Bronze
      |
  PySpark / Delta
      |
    Silver
      |
  PySpark / dbt
      |
     Gold
      |
 Analytics / BI
```

## 11. Data engineering learning roadmap

```text
Infrastructure → Governance → Raw data → Batch ingestion → Bronze → Silver
→ Gold → Data quality → Incremental processing → Streaming → CDC
→ Schema evolution → Spark optimization → dbt → Orchestration → CI/CD
→ Production-oriented deployment
```

## 12. Skill progress tracker

| Skill | Status |
| --- | --- |
| Terraform fundamentals | In Progress |
| AWS S3 foundation | In Progress |
| AWS IAM | Planned |
| Unity Catalog catalogs and schemas | In Progress |
| Storage credentials and external locations | Planned |
| Bronze / Silver / Gold structure | In Progress |
| Batch ingestion | Planned |
| Incremental ingestion / Auto Loader | Planned |
| Streaming / CDC / schema evolution | Planned |
| Delta Lake | Planned |
| PySpark | Planned |
| Spark optimization | Planned |
| dbt and data quality | Planned |
| Databricks Jobs / Asset Bundles | Planned |
| Airflow | Planned |
| Docker | Planned |
| CI/CD | Planned |
| Git / pull-request workflow | In Progress |

## 13. Git and pull-request workflow

```text
main
  |
feature branch
  |
implementation
  |
terraform fmt / validate / plan
  |
commit and push
  |
pull request
  |
review and merge
  |
delete feature branch
```

The project owner reviews and merges pull requests. Do not directly develop on
`main`.

## 14. Validation and deployment workflow

For every Terraform infrastructure change:

1. Format with `terraform fmt`.
2. Validate syntax with `terraform validate`.
3. Inspect the proposed change with `terraform plan`.
4. Commit only reviewed source and dependency-lock changes—never secrets or
   local state.
5. Submit a pull request and apply only after review and approval.

`terraform validate` currently passes. Terraform state is local and ignored by
Git, which is acceptable only for this single-developer learning stage.

## 15. Production-oriented practices

- Keep secrets out of source control and Terraform configuration.
- Use least-privilege IAM and Unity Catalog grants.
- Block public S3 access and use encryption and versioning.
- Use pull-request review and repeatable Terraform validation.
- Before team use or CI/CD, migrate from local state to encrypted remote state
  with locking and controlled access.

## 16. Architecture decisions

| Decision | Rationale |
| --- | --- |
| Root-level Terraform configuration | Keeps the early learning architecture transparent and inspectable. |
| Three environment catalogs | Separates development, staging, and production workloads. |
| Medallion schemas per catalog | Applies a consistent bronze/silver/gold topology in every environment. |
| Olist as the common domain | Lets each learning stage build on the same ecommerce platform. |
| Governance before ingestion | Prevents ungoverned access patterns from becoming part of the platform. |

## 17. Future data flow

```text
Governed Olist files in S3
    → Databricks ingestion
    → bronze raw Delta tables
    → silver cleaned and standardized tables
    → gold business-ready models
    → analytics and BI
```

This flow is planned; no dataset or pipeline has been implemented yet.

## 18. Definition of success

The project succeeds when it provides a reproducible, governed ecommerce
platform that demonstrates secure cloud access, reliable ingestion,
well-modeled bronze/silver/gold data, data quality, orchestration, deployment
automation, and clear documentation of the engineering decisions made.

## Immediate Next Action

S3 security configuration
