# Ecommerce Data Platform

> A hands-on data-engineering learning project with production discipline. The
> Olist Brazilian E-Commerce dataset is the common domain for progressively
> building one governed platform, not disconnected tutorials.

## 1. Project overview

This project builds an AWS and Databricks ecommerce data platform in deliberate
learning checkpoints. Infrastructure and governance come before ingestion so
later pipeline work begins on a secure foundation.

## 2. Project objective

Ingest Olist raw data from Amazon S3 into Databricks, process it through bronze,
silver, and gold layers, and make trusted data available for analytics. The
project also teaches infrastructure as code, governance, Spark, transformation,
orchestration, and delivery practices.

## 3. Current status

**Checkpoint:** 4 — Governed S3 Access

**Status:** In progress. Terraform manages the protected S3 foundation, IAM role
and policy, Unity Catalog storage credential, and external locations.
Least-privilege Unity Catalog grants and a live governed-access validation
remain.

The Olist dataset has not been downloaded or uploaded. No ingestion pipeline,
Delta table, dbt model, Databricks job, or CI/CD pipeline exists yet.

## 4. Completed checkpoints

| Checkpoint | Status | Evidence |
| --- | --- | --- |
| 1. Terraform setup | Completed | Version constraints and provider lock file are present; `terraform validate` passes. |
| 2. Databricks catalogs | Completed | Terraform manages development, staging, and production Unity Catalog catalogs. |
| 3. Medallion schemas | Completed | Terraform manages bronze, silver, and gold schemas in every catalog. |
| 4A. S3 foundation | Completed | Terraform manages dedicated raw-data and managed-storage buckets. |
| 4B. S3 security | Completed | Both buckets block public access, use AES-256 default encryption, have versioning, and are tagged. |
| 4C. IAM foundation | Completed | Terraform manages the Databricks S3-access role and policy. |
| 4D. Storage credential | Completed | Terraform manages the Unity Catalog S3 storage credential. |
| 4E. External locations | Completed | Terraform manages raw-data and managed-storage external locations. |

## 5. Current checkpoint

| Stage | Status | Scope |
| --- | --- | --- |
| 4F | In Progress | Define least-privilege Unity Catalog grants and review the broad current S3 policy. |
| 4G | Planned | Validate governed Databricks-to-S3 access. |

Only after 4G should the project acquire Olist data, upload it to the raw-data
location, and start ingestion.

## 6. Current Terraform architecture

The Terraform configuration is intentionally simple and root-level. Do not add
modules or refactor this layout at the current learning stage. A previous
Databricks-module experiment was abandoned and is not current architecture.

```text
terraform/
├── .terraform/                         Local provider cache (ignored)
├── .terraform.lock.hcl                 Committed provider dependency lock
├── aws_s3.tf                           S3 buckets and security settings
├── iam.tf                              Databricks S3-access role and policy
├── databricks_storage.tf               Unity Catalog storage credential
├── databricks_external_location.tf     Unity Catalog external locations
├── catalog.tf                          Databricks catalogs
├── schemas.tf                          Medallion schemas
├── providers.tf                        AWS and Databricks providers
├── variables.tf                        Bucket and AWS account inputs
├── versions.tf                         Terraform and provider constraints
└── local Terraform state files         Ignored
```

Terraform requires `>= 1.15.0, < 2.0.0`; Databricks is constrained to `~> 1.0`
and AWS to `~> 6.0`. AWS is deployed in `us-east-1`.

## 7. Current infrastructure inventory

Terraform local state contains **25 managed resources**.

| Platform | Resources | Current state |
| --- | --- | --- |
| AWS S3 | 2 buckets and 6 protection resources | `olist-data-platform-raw` and `olist-data-platform-databricks`; public access blocked, AES-256 default encryption, and versioning enabled. |
| AWS IAM | Role and role policy | `databricks-olist-access` supports Databricks S3 access; its permissions require least-privilege review. |
| Databricks | Storage credential and external locations | `olist-s3-storage-credential`, `olist-raw`, and `olist-databricks-managed`. |
| Databricks | Catalogs and schemas | Three environment catalogs, each with bronze, silver, and gold schemas. |

Managed catalog-storage roots:

```text
s3://olist-data-platform-databricks/catalogue/01_ecommerce_dev
s3://olist-data-platform-databricks/catalogue/02_ecommerce_stg
s3://olist-data-platform-databricks/catalogue/03_ecommerce_prod
```

## 8. Immediate next steps

1. Define least-privilege Unity Catalog grants for the storage credential and external locations.
2. Review and narrow the IAM S3 policy to the required actions and paths.
3. Validate governed Databricks-to-S3 access.
4. Only then acquire and upload Olist raw data.

## 9. Olist dataset and domain

The Olist Brazilian E-Commerce dataset is the planned source domain. No source
data is currently stored in the Terraform-managed buckets. It will be placed in
the governed raw-data location only after access is validated.

## 10. Target architecture

This is the target architecture, not the current implementation.

```text
Git / GitHub -> feature branches / pull requests -> CI/CD -> Terraform
                                                        |          |
                                                       AWS    Databricks
                                                        |          |
                                                        S3 -> Unity Catalog
                                                               |
                                               storage credential / external location
                                                               |
                                                         Olist raw data
                                                               |
                                                    batch or streaming ingestion
                                                               |
                                                 Bronze -> Silver -> Gold -> Analytics / BI
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
| Terraform | In Progress |
| AWS S3 | In Progress |
| AWS IAM | In Progress |
| Unity Catalog | In Progress |
| Bronze / Silver / Gold structure | In Progress |
| Git / PR workflow | In Progress |
| Batch ingestion, Incremental ingestion, Auto Loader | Planned |
| Streaming, CDC, schema evolution | Planned |
| Delta Lake, PySpark, Spark optimization | Planned |
| dbt and data quality | Planned |
| Databricks Jobs and Asset Bundles | Planned |
| Airflow, Docker, CI/CD | Planned |

## 13. Git and pull-request workflow

```text
main -> feature branch -> implementation -> terraform fmt / validate / plan
-> commit -> push -> pull request -> review -> merge -> delete branch
```

The project owner reviews and merges pull requests. Do not develop directly on
`main`.

## 14. Validation and deployment workflow

For each Terraform change, run `terraform fmt`, `terraform validate`, and
`terraform plan`; review the plan before applying. Commit only reviewed source
and dependency-lock changes—never secrets or local state.
`terraform validate` currently passes.

## 15. Production-oriented practices

- Keep credentials and state out of source control.
- Use least-privilege IAM and Unity Catalog grants.
- Keep S3 public access blocked, encrypted, and versioned.
- Use feature branches, pull-request review, and repeatable validation.
- Migrate to encrypted remote state with locking before team use or CI/CD applies.

## 16. Architecture decisions

| Decision | Rationale |
| --- | --- |
| Root-level Terraform | Keeps the current learning architecture transparent and inspectable. |
| Separate raw and managed-storage buckets | Separates source landing data from catalog managed storage. |
| Three environment catalogs | Isolates development, staging, and production workloads. |
| Medallion schemas per catalog | Provides a consistent bronze/silver/gold topology. |
| Governance before ingestion | Avoids normalizing ungoverned data-access patterns. |

## 17. Future data flow

```text
Governed Olist files in S3 -> Databricks ingestion -> bronze raw Delta tables
-> silver cleaned tables -> gold business models -> analytics and BI
```

This is planned; no dataset or pipeline has been implemented.

## 18. Definition of success

The finished project will be a reproducible, governed ecommerce platform that
demonstrates secure cloud access, reliable ingestion, well-modelled medallion
data, data quality, orchestration, deployment automation, and clear engineering
decisions.

## Immediate Next Action

Define least-privilege Unity Catalog grants and validate governed access.
