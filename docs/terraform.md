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

The first connection will use a Databricks personal access token (PAT). Keep the
workspace URL and PAT only in the local `.env` file, which Git ignores:

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

## Planned sequence

1. Configure `DATABRICKS_HOST` and `DATABRICKS_TOKEN` locally.
2. Add a provider-only Terraform configuration. **Completed.**
3. Run `terraform init` and `terraform validate`. **Completed.**
4. Run a read-only Terraform connectivity test.
5. Import the manually created `ecommerce` catalog before Terraform manages it.
6. Add Terraform-managed `bronze`, `silver`, and `gold` schemas.

## Change management

Terraform changes are made on a dedicated branch, documented in the project
journal, validated locally, and submitted through a pull request. The project
owner creates and merges the pull request; automated work never writes directly
to `main`.

## References

- [Databricks Terraform provider documentation](https://docs.databricks.com/aws/en/dev-tools/terraform/)
- [Databricks unified authentication environment variables](https://docs.databricks.com/aws/en/dev-tools/auth/env-vars)
- [Databricks personal access token authentication](https://docs.databricks.com/aws/en/dev-tools/auth/pat)
