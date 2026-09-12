# Terraform Infrastructure

Terraform manages all AWS and Databricks infrastructure for the Olist Data Platform. The configuration is root-level (no modules) and uses local state.

## File Layout

| File | Responsibility |
|---|---|
| `versions.tf` | Terraform and provider version constraints |
| `providers.tf` | AWS and Databricks provider configuration |
| `variables.tf` | Input variables (bucket names, AWS account ID) |
| `aws_s3.tf` | S3 buckets and security configuration |
| `iam.tf` | IAM role and policy for Databricks S3 access |
| `databricks_storage.tf` | Unity Catalog storage credential |
| `databricks_external_location.tf` | Unity Catalog external locations |
| `catalog.tf` | Unity Catalog catalogs (dev, stg, prod) |
| `schemas.tf` | Medallion schemas (bronze, silver, gold per catalog) |
| `.terraform.lock.hcl` | Provider dependency lock (committed to git) |

## Version Constraints

| Component | Constraint |
|---|---|
| Terraform | `>= 1.15.0, < 2.0.0` |
| `databricks/databricks` | `~> 1.0` |
| `hashicorp/aws` | `~> 6.0` |

## Authentication

| Provider | Method |
|---|---|
| Databricks | Unified authentication via `DATABRICKS_HOST` and `DATABRICKS_TOKEN` environment variables from `.env` |
| AWS | Standard credential chain via `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION` environment variables |

No credentials are stored in Terraform source files. The `.env` file is gitignored.

## Variables

| Variable | Description | Default |
|---|---|---|
| `aws_account_id` | AWS account ID | `702127848749` |
| `raw_bucket_name` | S3 bucket for raw source data | `olist-data-platform-raw` |
| `databricks_bucket_name` | S3 bucket for Databricks managed storage | `olist-data-platform-databricks` |

## Managed Resources

Local state tracks **25 resource instances** (17 top-level resource entries; `databricks_schema.medallion` creates 9 instances via `for_each`).

### AWS Resources

| Resource | Name | Purpose |
|---|---|---|
| `aws_s3_bucket.raw_data` | `olist-data-platform-raw` | Raw source data landing zone |
| `aws_s3_bucket.databricks_data` | `olist-data-platform-databricks` | Databricks managed catalog storage |
| `aws_s3_bucket_public_access_block` | (both buckets) | Block all public access |
| `aws_s3_bucket_server_side_encryption_configuration` | (both buckets) | AES-256 default encryption |
| `aws_s3_bucket_versioning` | (both buckets) | Object versioning enabled |
| `aws_iam_role.databricks_olist_access` | `databricks-olist-access` | IAM role for Databricks S3 access |
| `aws_iam_role_policy.databricks_olist_s3` | `databricks-olist-s3-access` | Inline S3 access policy |

### Databricks Resources

| Resource | Name | Purpose |
|---|---|---|
| `databricks_storage_credential.olist_s3` | `olist-s3-storage-credential` | Unity Catalog storage credential backed by IAM role |
| `databricks_external_location.olist_raw` | `olist-raw` | Maps to `s3://olist-data-platform-raw/raw/` |
| `databricks_external_location.databricks_managed` | `olist-databricks-managed` | Maps to `s3://olist-data-platform-databricks/catalogue/` |
| `databricks_catalog.catalog_01_ecommerce_dev` | `01_ecommerce_dev` | Development catalog |
| `databricks_catalog.catalog_02_ecommerce_stg` | `02_ecommerce_stg` | Staging catalog |
| `databricks_catalog.catalog_03_ecommerce_prod` | `03_ecommerce_prod` | Production catalog |
| `databricks_schema.medallion` | `bronze`, `silver`, `gold` × 3 catalogs | 9 medallion schema instances |

### Catalog Storage Roots

```text
s3://olist-data-platform-databricks/catalogue/01_ecommerce_dev
s3://olist-data-platform-databricks/catalogue/02_ecommerce_stg
s3://olist-data-platform-databricks/catalogue/03_ecommerce_prod
```

## Validation Workflow

From the `terraform/` directory:

```bash
terraform fmt        # Format configuration files
terraform validate   # Validate configuration syntax and references
terraform plan       # Preview changes (requires live credentials)
terraform apply      # Apply changes (only after plan review)
```

Always run `fmt` → `validate` → `plan` → review before applying. Never apply without reviewing the plan.

## State Management

- State is stored locally as `terraform.tfstate` in the `terraform/` directory.
- State files are gitignored via `*.tfstate` and `*.tfstate.*` patterns.
- State contains sensitive infrastructure metadata and must not be shared or committed.

> [!WARNING]
> **Planned**: Migrate to encrypted remote state with locking before team use or CI/CD integration. Local state is appropriate only for single-developer operation.

## Rules for Infrastructure Changes

1. Never add credentials to Terraform source files.
2. Never commit state files, `.tfvars` files, or `.terraform/` contents.
3. Always run `terraform fmt` and `terraform validate` before committing.
4. Always review `terraform plan` output before applying.
5. Do not introduce Terraform modules — the configuration is intentionally root-level.
6. Do not modify resource naming conventions without updating dependent configurations (DAB job definitions, documentation).
7. Do not remove S3 security controls (public access blocking, encryption, versioning).
8. IAM policy changes require security review — see [security.md](security.md).
9. Unity Catalog structural changes (catalogs, schemas) require documentation updates.

## References

- [Databricks Terraform provider documentation](https://docs.databricks.com/aws/en/dev-tools/terraform/)
- [Databricks unified authentication environment variables](https://docs.databricks.com/aws/en/dev-tools/auth/env-vars)
