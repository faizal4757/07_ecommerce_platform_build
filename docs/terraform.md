# Terraform and Databricks

> **Learning project, production discipline.** We use this project to understand
> Terraform and Unity Catalog step by step while applying production practices:
> no secrets in code, explicit version constraints, committed dependency locks,
> validation before deployment, and pull-request review.

## Purpose

Terraform is the infrastructure-as-code tool for this project. Its Databricks
provider calls Databricks APIs so Unity Catalog infrastructure can be described,
reviewed, and deployed from version-controlled files.

Terraform will manage the desired state. It compares that state with the actual
Databricks state and proposes the changes needed to reconcile them.

## Learning-project authentication

This learning project uses a Databricks personal access token (PAT) for local
Terraform authentication. Keep the workspace URL and PAT only in the local
`.env` file, which Git ignores:

```dotenv
DATABRICKS_HOST=https://<your-workspace-url>
DATABRICKS_TOKEN=<your-personal-access-token>
```

The provider automatically recognizes these unified-authentication environment
variables. The Terraform configuration therefore contains no secret values.

For production automation, use a service principal with OAuth credentials rather
than a developer's personal token.

## What `terraform init` does

`terraform init` prepares one Terraform working directory. In this project it
will download the pinned Databricks provider into the ignored `.terraform/`
directory and create/update `.terraform.lock.hcl` with the selected provider
version and checksums. The lock file is committed; the `.terraform/` directory
is not.

It does not create, change, or delete any Databricks resources.

## Implemented provider and catalog baseline

The Terraform configuration is initialized with the locked
`databricks/databricks` provider and passes `terraform validate`. Terraform has
successfully applied the following catalog resources:

| Environment | Catalog | Managed storage root |
| --- | --- | --- |
| Development | `01_ecommerce_dev` | `s3://ecommerce-pipeline-faizal-dev/catalogue/01_ecommerce_dev` |
| Staging | `02_ecommerce_stg` | `s3://ecommerce-pipeline-faizal-dev/catalogue/02_ecommerce_stg` |
| Production | `03_ecommerce_prod` | `s3://ecommerce-pipeline-faizal-dev/catalogue/03_ecommerce_prod` |

The catalog names deliberately encode both ordering and environment. Each has
Terraform properties for `environment`, `project = ecommerce`, and
`managed_by = terraform`.

## Implemented medallion schema baseline

The three-layer medallion structure is now deployed in every catalog. A local
`schemas` map defines the catalog and schema name for each environment/layer
combination, and `databricks_schema.medallion` uses `for_each` to create the
nine schema resources. The result is consistent, environment-isolated names:

| Environment | Schemas |
| --- | --- |
| Development | `01_ecommerce_dev.bronze`, `.silver`, `.gold` |
| Staging | `02_ecommerce_stg.bronze`, `.silver`, `.gold` |
| Production | `03_ecommerce_prod.bronze`, `.silver`, `.gold` |

This is a useful production pattern when environments share the same topology:
the declarative map is easy to review, avoids nine repetitive resource blocks,
and keeps Terraform resource addresses stable through their map keys.

## Planned sequence

1. Configure `DATABRICKS_HOST` and `DATABRICKS_TOKEN` locally. **Completed.**
2. Add provider configuration. **Completed.**
3. Run `terraform init` and `terraform validate`. **Completed.**
4. Create and apply the dev, staging, and production catalogs. **Completed.**
5. Add Terraform-managed `bronze`, `silver`, and `gold` schemas to each catalog. **Completed.**
6. Add storage credentials, external locations, and least-privilege grants.
7. Add remote Terraform state and CI/CD before collaborative deployments.

## State and production considerations

The current Terraform state is local and ignored by Git, which is appropriate
for this single-developer learning checkpoint. A production implementation must
use encrypted remote state with locking and controlled access before multiple
people or CI/CD can apply infrastructure changes.

The current catalog `storage_root` values are managed-storage roots. They are
not replacements for governed raw-data access. When S3 raw-data ingestion is
implemented, use a Unity Catalog storage credential and external location with
least-privilege permissions rather than embedding cloud credentials in code.

The current local state represents 12 Terraform-managed resources: three
catalogs and nine schemas. Before a team or CI/CD applies further changes,
migrate this state to a remote backend and agree the state-access model.

## Change management

Terraform changes are made on a dedicated branch, documented in the project
journal, validated locally, and submitted through a pull request. The project
owner creates and merges the pull request; automated work never writes directly
to `main`.

## References

- [Databricks Terraform provider documentation](https://docs.databricks.com/aws/en/dev-tools/terraform/)
- [Databricks unified authentication environment variables](https://docs.databricks.com/aws/en/dev-tools/auth/env-vars)
- [Databricks personal access token authentication](https://docs.databricks.com/aws/en/dev-tools/auth/pat)
