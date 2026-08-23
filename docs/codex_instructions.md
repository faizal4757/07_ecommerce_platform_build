Update the project's project.md to become the authoritative master
checkpoint and learning roadmap for this data engineering project.

IMPORTANT RULES:
1. Do NOT modify Terraform files, infrastructure, code, Git configuration,
   or any other project files.
2. ONLY modify project.md.
3. Preserve accurate historical information already present in project.md.
4. Do not claim anything is completed unless it is actually completed in the
   repository/current project state.
5. Clearly distinguish COMPLETED, IN PROGRESS, and PLANNED work.
6. Do not invent resources, architecture, datasets, pipelines, or
   implementations.
7. Do not introduce Terraform modules or refactor the current Terraform
   structure.
8. The current Terraform architecture is intentionally simple and root-level.
9. project.md must remain understandable to me as a learning checkpoint,
   not just as documentation for another developer.

FIRST inspect the repository and existing project.md so that the updated
document reflects the actual current state.

CURRENT PROJECT DIRECTION:

This is a hands-on data engineering learning project with production
discipline.

The primary ecommerce domain/dataset for the data engineering portion will be
the Olist Brazilian E-Commerce dataset.

The purpose is NOT simply to build a pipeline. The project should progressively
teach modern data engineering skills by implementing them inside one coherent
ecommerce platform.

CURRENT COMPLETED STATE:

Terraform:
- Terraform is installed and working.
- Databricks provider is configured.
- AWS provider is configured.
- Terraform version constraints are present.
- Provider dependency lock file is committed.
- terraform validate passes.
- Terraform plan is used before deployment.
- Terraform state is currently local for this single-developer learning
  project.
- Terraform secrets must not be stored in source code.

Databricks:
- 3 catalogs are Terraform-managed:
  - 01_ecommerce_dev
  - 02_ecommerce_stg
  - 03_ecommerce_prod
- 9 medallion schemas are Terraform-managed:
  - dev_bronze
  - dev_silver
  - dev_gold
  - stg_bronze
  - stg_silver
  - stg_gold
  - prod_bronze
  - prod_silver
  - prod_gold

AWS:
- AWS provider has been added to Terraform.
- AWS region is us-east-1.
- A dedicated S3 bucket has been created through Terraform:
  olist-data-platform-faizal
- Terraform resource:
  aws_s3_bucket.olist_data
- The bucket is currently empty.
- Olist data has NOT yet been loaded.

CURRENT TERRAFORM STRUCTURE:

terraform/
├── .terraform/
├── .terraform.lock.hcl
├── aws_s3.tf
├── catalog.tf
├── providers.tf
├── schemas.tf
├── versions.tf
└── terraform state files

The previous experiment to move Databricks resources into
terraform/modules/databricks was abandoned.

IMPORTANT:
The project intentionally returned to the simpler root-level Terraform
configuration. Do not describe the module refactor as current architecture.
If documenting it at all, describe it only as an abandoned experiment.

CURRENT RESOURCE COUNT:

13 Terraform-managed resources:
- 3 Databricks catalogs
- 9 Databricks schemas
- 1 AWS S3 bucket

CURRENT CHECKPOINT:

Checkpoint 4: Governed S3 Access

Checkpoint 4A is complete:
- AWS provider added
- Olist S3 bucket created with Terraform
- Bucket is tracked in Terraform state
- Existing Databricks resources remain unchanged

NEXT IMPLEMENTATION SEQUENCE:

Checkpoint 4B:
- S3 public access blocking
- S3 encryption
- S3 versioning
- S3 tags

Checkpoint 4C:
- AWS IAM
- IAM roles
- Trust policies
- Least-privilege permissions

Checkpoint 4D:
- Unity Catalog storage credential

Checkpoint 4E:
- Unity Catalog external location

Checkpoint 4F:
- Least-privilege Unity Catalog grants

Checkpoint 4G:
- Validate governed Databricks-to-S3 access

Only after the governance layer is established:
- Acquire/download the Olist dataset
- Upload raw data to S3
- Build ingestion pipelines

LONG-TERM LEARNING ROADMAP:

Infrastructure and Cloud:
- Terraform
- AWS S3
- AWS IAM
- Infrastructure as Code
- Terraform state
- Remote state
- CI/CD

Databricks and Lakehouse:
- Unity Catalog
- Storage credentials
- External locations
- Grants
- Bronze/Silver/Gold
- Delta Lake
- Databricks Jobs
- Databricks Asset Bundles

Data Ingestion:
- Batch ingestion
- Incremental ingestion
- Auto Loader
- Streaming
- Change Data Capture
- Schema evolution

Spark:
- PySpark
- DataFrame transformations
- Joins
- Partitioning
- Shuffle
- Adaptive Query Execution
- Spark performance optimization
- Data skew
- Execution plans

Transformation / Analytics Engineering:
- dbt
- Staging models
- Intermediate models
- Mart models
- Incremental models
- Data quality testing
- Documentation
- Lineage

Orchestration:
- Databricks Jobs
- Databricks Asset Bundles
- Airflow
- Scheduling
- Dependencies
- Retries
- Failure handling

Engineering / DevOps:
- Git
- Feature branches
- Pull requests
- Code review
- CI/CD
- Docker
- Automated testing
- Deployment validation

IMPORTANT LEARNING PRINCIPLE:

Do not turn each technology into a disconnected tutorial.

Use the Olist ecommerce domain as the common thread and progressively evolve the
same platform.

The intended progression is:

Infrastructure
→ Governance
→ Raw data
→ Batch ingestion
→ Bronze
→ Silver
→ Gold
→ Data quality
→ Incremental processing
→ Streaming
→ CDC
→ Schema evolution
→ Spark optimization
→ dbt
→ Orchestration
→ CI/CD
→ Production-oriented deployment

TARGET ARCHITECTURE:

Git/GitHub
    |
    v
Feature branches / Pull Requests
    |
    v
CI/CD
    |
    v
Terraform
   / \
  /   \
AWS   Databricks
 |       |
S3    Unity Catalog
 |       |
 |   Storage Credential
 |       |
 |   External Location
 |       |
 +-------+
    |
 Olist raw data
    |
 Batch / Streaming
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

Clearly label this as TARGET ARCHITECTURE because most of it is not yet
implemented.

GIT / PR WORKFLOW:

Document the project's intended workflow:

main
  |
feature branch
  |
implementation
  |
terraform fmt / validate / plan
  |
commit
  |
push
  |
pull request
  |
review
  |
merge
  |
delete feature branch
  |
new feature branch

The project owner reviews and merges pull requests.

Do not directly develop on main.

SKILL TRACKER:

Create a useful table showing each major skill and whether it is:
- Completed
- In Progress
- Planned

Do not mark future skills as completed.

Suggested skills:
- Terraform
- AWS S3
- AWS IAM
- Unity Catalog
- Batch ingestion
- Incremental ingestion
- Auto Loader
- Streaming
- CDC
- Schema evolution
- Delta Lake
- Bronze/Silver/Gold
- PySpark
- Spark optimization
- dbt
- Data quality
- Databricks Jobs
- Databricks Asset Bundles
- Airflow
- Docker
- CI/CD
- Git / PR workflow

DOCUMENTATION STRUCTURE:

Organize project.md roughly as:

1. Project overview
2. Project objective
3. Current status
4. Completed checkpoints
5. Current checkpoint
6. Current Terraform architecture
7. Current infrastructure/resource inventory
8. Immediate next steps
9. Olist dataset/domain
10. Target architecture
11. Data engineering learning roadmap
12. Skill progress tracker
13. Git/PR workflow
14. Validation/deployment workflow
15. Production-oriented practices
16. Architecture decisions
17. Future data flow
18. Definition of success
19. Immediate next action

Keep the document concise enough to remain useful as a living checkpoint.
Avoid turning it into a textbook.

At the very end, include a clearly visible:

"## Immediate Next Action"

with:

"S3 security configuration"

as the next implementation task.

After editing project.md, show me a concise summary of:
- what sections were added/updated
- what was marked completed
- what remains planned

Do not modify any other files.