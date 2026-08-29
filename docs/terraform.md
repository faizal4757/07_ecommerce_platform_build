# Terraform and Databricks

Terraform manages the root-level AWS S3 and IAM resources alongside Databricks
Unity Catalog resources. This simple layout is intentional for the current
learning stage; it does not use Terraform modules.

## Authentication and validation

Databricks uses unified authentication from the local, ignored `.env` file:

```dotenv
DATABRICKS_HOST=https://<your-workspace-url>
DATABRICKS_TOKEN=<your-personal-access-token>
```

AWS uses the normal local credential chain in `us-east-1`; neither provider's
credentials belong in Terraform source. Terraform requires `>= 1.15.0, < 2.0.0`.
The locked providers are `databricks/databricks ~> 1.0` and
`hashicorp/aws ~> 6.0`.

From `terraform/`, run `terraform init`, `terraform fmt`,
`terraform validate`, and `terraform plan` before an infrastructure change.
`terraform validate` currently passes. A plan requires live cloud credentials
and must be reviewed before applying.

## Managed infrastructure

Local state currently tracks 25 resources.

| Area | Resources |
| --- | --- |
| S3 | Raw-data and Databricks-managed-storage buckets, each with public-access blocking, AES-256 default encryption, and versioning |
| IAM | `databricks-olist-access` role and its S3 access policy |
| Unity Catalog | One storage credential and two external locations |
| Catalogs | `01_ecommerce_dev`, `02_ecommerce_stg`, `03_ecommerce_prod` |
| Schemas | `bronze`, `silver`, and `gold` in each catalog (nine schemas) |

The buckets are `olist-data-platform-raw` and
`olist-data-platform-databricks`. External locations point to
`s3://olist-data-platform-raw/raw/` and
`s3://olist-data-platform-databricks/catalogue/`.

## Current checkpoint and next work

Checkpoint 4 (Governed S3 Access) has completed its S3 foundation and security,
IAM role/policy, Unity Catalog storage credential, and external-location work.
Next, define least-privilege Unity Catalog grants, review and narrow the current
broad IAM S3 policy where appropriate, then validate Databricks-to-S3 access.
The Olist dataset has not been loaded and no ingestion pipeline exists.

## State and production considerations

State is local and ignored by Git, suitable only for this single-developer
learning stage. Before team use or CI/CD applies, migrate to encrypted remote
state with locking and controlled access. Do not commit `.env`, state files,
`.terraform/`, or cloud credentials.

## References

- [Databricks Terraform provider documentation](https://docs.databricks.com/aws/en/dev-tools/terraform/)
- [Databricks unified authentication environment variables](https://docs.databricks.com/aws/en/dev-tools/auth/env-vars)
