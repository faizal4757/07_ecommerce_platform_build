# ecommerce-data-platform

## Project Checkpoint

**Checkpoint:** 1
**Phase:** Terraform + Unity Catalog Infrastructure
**Status:** Terraform installed and ready
**Last completed step:** Terraform installation and PATH configuration

---

# 1. Project Goal

Build a realistic production-style **Ecommerce Data Engineering Platform** using:

* AWS S3
* Databricks
* Unity Catalog
* PySpark
* Terraform
* dbt
* Databricks Asset Bundles (DAB)
* Git
* CI/CD

The goal is not only to build the pipeline, but to understand **why each component exists, how they interact, and how the same architecture would be managed in production.**

---

# 2. Target Architecture

The intended high-level architecture is:

```text
                         ecommerce-data-platform
                                  |
                 +----------------+----------------+
                 |                                 |
                AWS                            Databricks
                 |                                 |
                S3                            Unity Catalog
                 |                                 |
             Raw Data                     ecommerce Catalog
                 |                                 |
                 |                     +-----------+-----------+
                 |                     |           |           |
                 |                  bronze      silver       gold
                 |                     |           |           |
                 |                     |          dbt         dbt
                 |                     |           |           |
                 +---------------------+-----------+-----------+
                                       |
                                  Analytics / BI
```

More specifically:

```text
S3 Raw Data
    |
    | PySpark / Auto Loader
    v
Bronze
    |
    | dbt
    v
Silver
    |
    | dbt
    v
Gold
```

---

# 3. Unity Catalog Hierarchy

The core Unity Catalog hierarchy we are using is:

```text
Catalog
   |
   +-- Schema
         |
         +-- Table
         +-- View
         +-- Function
```

For this project:

```text
ecommerce                    <-- Catalog
|
+-- bronze                   <-- Schema
|
+-- silver                   <-- Schema
|
+-- gold                     <-- Schema
```

Tables will eventually look like:

```text
ecommerce.bronze.orders
ecommerce.silver.orders
ecommerce.gold.daily_sales
```

The three-level namespace is:

```text
catalog.schema.object
```

---

# 4. Current Databricks State

The `ecommerce` catalog has already been created manually through the Databricks UI.

Current state:

```text
Unity Catalog
|
+-- ecommerce
      |
      +-- default
      |
      +-- information_schema
```

The following schemas have **not yet been created**:

```text
ecommerce.bronze
ecommerce.silver
ecommerce.gold
```

These will eventually be created using Terraform as part of the infrastructure-as-code exercise.

---

# 5. Unity Catalog Concepts Already Covered

## Catalog

A catalog is the top-level namespace in Unity Catalog.

Example:

```text
ecommerce
```

## Schema

A schema organizes tables, views, functions, etc.

Example:

```text
ecommerce.bronze
```

## Table

A table contains structured data.

Example:

```text
ecommerce.bronze.orders
```

## View

A view stores a query definition rather than being an independent copy of the underlying dataset.

## Volume

A Volume is used for governing files that are not necessarily tables.

Examples:

```text
JSON
CSV
PDF
images
other files
```

## External Location

An External Location represents and governs access to an external cloud-storage location such as an S3 path.

Example:

```text
s3://company-data/raw/
```

## Storage Credential

A Storage Credential represents the authentication/authorization mechanism used to access external cloud storage.

Conceptually:

```text
Databricks
    |
Storage Credential
    |
AWS IAM
    |
S3
```

## Connection

A Unity Catalog Connection represents connectivity to an external system such as a database or service.

---

# 6. Catalog Types Covered

We discussed the major catalog types shown in the Databricks UI.

## Standard Catalog

Normal Unity Catalog catalog used for Databricks-managed analytical data.

Example:

```text
ecommerce
```

## Foreign Catalog

Represents an external database/catalog.

Examples:

```text
PostgreSQL
MySQL
SQL Server
```

The data remains in the external system.

## Shared Catalog

Represents data shared through mechanisms such as Delta Sharing.

The recipient does not necessarily own the underlying data.

## Lakebase Postgres Catalog

Represents Databricks Lakebase/PostgreSQL data and is oriented more toward application/transactional workloads.

---

# 7. Managed vs External Storage

This distinction is extremely important.

## Managed Table

Unity Catalog manages the table's underlying storage and lifecycle.

Conceptually:

```text
Unity Catalog
    |
Catalog
    |
Managed Table
    |
Managed Storage Location
    |
S3
```

## External Table

The data already exists at a storage location controlled outside the table lifecycle.

Example:

```text
S3
|
+-- raw/
     |
     +-- orders/
```

Unity Catalog registers and governs the data without taking ownership of its underlying lifecycle in the same way as a managed table.

---

# 8. Catalog Managed Storage

A catalog can have a managed storage location.

Conceptually:

```text
ecommerce
    |
    +-- Managed Storage Location
             |
             v
       s3://.../ecommerce/
```

When a managed table is created under that catalog, Databricks can store the table's underlying files in that managed storage area.

Important:

**The catalog itself does not contain the physical table rows.**

The actual data remains in cloud object storage such as S3.

---

# 9. Important S3 Duplication Concept

Our source data is already in S3.

Conceptually:

```text
S3
|
+-- raw/
     |
     +-- orders.csv
```

If we read that file and create a new managed Delta table:

```text
S3
|
+-- raw/
|    |
|    +-- orders.csv
|
+-- managed/
     |
     +-- ecommerce/
          |
          +-- managed Delta table files
```

then there can be two physical datasets.

This is not caused simply by creating a catalog.

The duplication happens because we:

```text
read source data
      |
      v
write another dataset
```

This is often intentional in a medallion architecture.

---

# 10. Intended Medallion Architecture

The intended pipeline is:

```text
S3 Raw
   |
   v
Bronze
   |
   v
Silver
   |
   v
Gold
```

Bronze:

* Raw/near-raw ingested data
* Primarily ingestion responsibility
* PySpark / Auto Loader or similar technology

Silver:

* Cleaned
* Validated
* Standardized
* Transformed
* dbt can manage transformations

Gold:

* Business-ready
* Aggregated
* Analytics-oriented
* dbt can manage transformations

---

# 11. dbt Role

dbt is primarily being used for **data transformation**, not initial raw ingestion.

Conceptual flow:

```text
Bronze
   |
   | dbt
   v
Silver
   |
   | dbt
   v
Gold
```

A dbt model might look like:

```sql
SELECT
    order_id,
    customer_id,
    product_id,
    quantity,
    unit_price
FROM {{ ref('stg_orders') }}
```

dbt compiles the model's SQL and then materializes the result in Databricks according to the model configuration.

Important distinction:

```text
Schema != dbt Model
```

For example:

```text
ecommerce.silver
```

is a schema.

```text
orders.sql
```

can be a dbt model.

The dbt model may eventually materialize as:

```text
ecommerce.silver.orders
```

---

# 12. Terraform Role

Terraform will be used to manage infrastructure and governance declaratively.

Expected responsibilities include things such as:

```text
Terraform
|
+-- Catalog
+-- Schemas
+-- Storage Credentials
+-- External Locations
+-- Permissions
+-- Other infrastructure/configuration
```

Instead of manually doing:

```sql
CREATE SCHEMA ecommerce.bronze;
```

in production, we can define the desired infrastructure as code.

Conceptually:

```text
Git
 |
Terraform
 |
Databricks
 |
Unity Catalog
 |
ecommerce.bronze
```

---

# 13. DAB Role

Databricks Asset Bundles (DAB) will be considered for deployment of Databricks project assets.

Potential responsibilities:

```text
DAB
|
+-- Databricks Jobs
+-- Python code
+-- Notebooks
+-- SQL
+-- Pipelines
+-- Job configuration
+-- Deployment configuration
```

DAB and Terraform are not necessarily mutually exclusive.

The exact division depends on the organization's production platform standards.

---

# 14. Tool Responsibilities

Current mental model:

```text
Terraform
    |
    +-- Infrastructure / governance
    |
    +-- Catalogs
    +-- Schemas
    +-- Storage
    +-- Permissions


DAB
    |
    +-- Databricks application assets
    |
    +-- Jobs
    +-- Python code
    +-- Notebooks
    +-- Pipelines


PySpark / Auto Loader
    |
    +-- Ingestion
    +-- Processing
    +-- Bronze


dbt
    |
    +-- Transformations
    +-- Silver
    +-- Gold
    +-- Tests
    +-- Documentation


Git / CI/CD
    |
    +-- Version control
    +-- Pull requests
    +-- Testing
    +-- Deployment
```

---

# 15. Terraform Installation Status

Terraform is installed locally on Windows.

Terraform executable:

```text
C:\Terraform\terraform.exe
```

Architecture:

```text
windows_amd64
```

Terraform version:

```text
Terraform v1.15.9
```

The `C:\Terraform` directory has been added to the Windows PATH.

The following command now works from a fresh CMD window:

```cmd
terraform --version
```

Expected output:

```text
Terraform v1.15.9
on windows_amd64
```

---

# 16. Terraform Status

Completed:

```text
Terraform executable              ✅
Correct AMD64 version             ✅
C:\Terraform                      ✅
Windows PATH                      ✅
terraform --version               ✅
```

Not yet completed:

```text
Terraform project directory       ⏳
Terraform configuration            ⏳
Databricks provider                ⏳
Databricks authentication          ⏳
terraform init                     ⏳
Terraform -> Databricks test       ⏳
Catalog via Terraform              ⏳
Schemas via Terraform              ⏳
Storage configuration              ⏳
Permissions                        ⏳
```

---

# 17. Current Project Repository

The intended project name is:

```text
ecommerce-data-platform
```

The repository will eventually evolve toward something like:

```text
ecommerce-data-platform/
|
+-- terraform/
|
+-- databricks/
|
+-- src/
|    |
|    +-- ingestion/
|
+-- dbt/
|
+-- tests/
|
+-- docs/
|
+-- resources/
|
+-- databricks.yml
|
+-- README.md
|
+-- .gitignore
```

This structure is **not fully created yet**.

Do not assume every directory above already exists.

---

# 18. S3 Status

An ecommerce source dataset already exists in S3.

Known conceptual structure:

```text
S3
|
+-- raw/
     |
     +-- orders/
```

Exact bucket name and complete path should be verified before being placed into Terraform configuration.

Potential future structure:

```text
S3
|
+-- raw/
|
+-- managed/
     |
     +-- ecommerce/
          |
          +-- bronze/
          +-- silver/
          +-- gold/
```

This is an architectural target, not necessarily the current physical S3 structure.

---

# 19. Production SDLC Mental Model

The intended production workflow is:

```text
Developer
   |
   v
Git branch
   |
   v
Code changes
   |
   v
Pull Request
   |
   v
CI tests
   |
   v
Merge
   |
   +-------------------+
   |                   |
   v                   v
Terraform             dbt / DAB
   |                   |
   v                   v
Infrastructure       Data / Jobs
   |                   |
   +---------+---------+
             |
             v
        Databricks
```

The goal is to avoid relying on manual UI changes in production.

The Databricks UI remains extremely useful for:

* Learning
* Debugging
* Exploration
* Inspecting execution
* Understanding how resources behave

But production changes should generally be represented as code and deployed through controlled processes.

---

# 20. Current Learning Strategy

We are deliberately building the platform incrementally.

Do not jump directly into a complete production architecture.

The learning sequence is:

```text
1. Understand Databricks UI
        |
        v
2. Understand Unity Catalog
        |
        v
3. Terraform
        |
        v
4. Create infrastructure through Terraform
        |
        v
5. Ingestion
        |
        v
6. Bronze
        |
        v
7. dbt
        |
        v
8. Silver
        |
        v
9. Gold
        |
        v
10. DAB
        |
        v
11. CI/CD
```

The reason is to understand what the automation is actually automating.

---

# 21. Current Checkpoint

## Completed

```text
Databricks / Unity Catalog concepts     ✅
ecommerce catalog created               ✅
Terraform installed                     ✅
Terraform PATH configured               ✅
terraform --version works               ✅
```

## Current stopping point

Terraform is installed, but it has **not yet been connected to Databricks**.

---

# 22. NEXT TASK

## Checkpoint 2: Create Terraform Project

First create:

```text
ecommerce-data-platform/
|
+-- terraform/
```

Then configure the Databricks Terraform provider.

The intended flow is:

```text
Local Machine
     |
     v
Terraform Project
     |
     v
Databricks Provider
     |
     v
Authentication
     |
     v
Databricks Workspace
```

Only after Terraform can successfully communicate with Databricks should we create the `ecommerce` catalog and its schemas through Terraform.

---

# 23. Immediate Next Action

From the desired project location:

```cmd
mkdir ecommerce-data-platform
cd ecommerce-data-platform
mkdir terraform
cd terraform
```

Then verify the working directory.

**Do not create the `.tf` files until the project directory is confirmed.**

The next discussion should explain:

1. What the Databricks Terraform provider is
2. How Terraform authenticates to Databricks
3. Which authentication method we should use for this learning project
4. What `terraform init` actually does
5. Then create the first Terraform configuration

---

# 24. Important Rule for Continuing This Project

Do not assume that a resource exists merely because it appears in the target architecture.

Always distinguish:

```text
CURRENT STATE
```

from:

```text
TARGET STATE
```

For example:

```text
CURRENT:
ecommerce catalog exists

TARGET:
ecommerce
├── bronze
├── silver
└── gold
```

This distinction is important because Terraform works by comparing:

```text
Desired State
      vs
Actual State
```

and determining what changes are required.

---

# END OF CHECKPOINT
