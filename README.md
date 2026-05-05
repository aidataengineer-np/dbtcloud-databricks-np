# HR Analytics dbt Project on Azure Databricks + Unity Catalog

This is a **dbt-only** project for an HR analytics lakehouse on Databricks Unity Catalog. It intentionally does **not** use Databricks Asset Bundles (DAB).

The project demonstrates:

- GitHub-ready dbt folder structure
- Unity Catalog naming standards
- Bronze / Silver / Gold medallion architecture
- dbt sources, seeds, models, snapshots, macros, tests, docs, exposures, analyses, vars, hooks, and packages
- Dynamic transformation rules stored in a governed Unity Catalog Delta table
- Reusable Jinja macros for rule-driven SQL generation
- Incremental merge models on Databricks Delta
- SCD Type 2 using dbt snapshots

---

## 1. Unity Catalog Naming Standard

Recommended environment/domain catalogs:

| Environment | Catalog |
|---|---|
| Development | `hr_dev` |
| QA | `hr_qa` |
| Production | `hr_prod` |

Recommended schemas:

| Schema | Purpose |
|---|---|
| `bronze` | Raw/source-aligned tables from Workday, Dayforce, recruiting, files, APIs |
| `config` | Governed metadata/rules tables |
| `silver` | Cleaned, deduplicated, conformed HR entities |
| `gold` | Dimensions, facts, KPI marts, BI-ready tables |
| `snapshots` | dbt SCD Type 2 snapshot tables |

Example physical objects:

```sql
hr_dev.bronze.employee_raw
hr_dev.bronze.department_raw
hr_dev.bronze.job_raw
hr_dev.bronze.payroll_raw
hr_dev.config.transformation_rules
hr_dev.silver.stg_workday_employee
hr_dev.silver.silver_employee
hr_dev.silver.silver_department
hr_dev.silver.silver_job
hr_dev.silver.silver_payroll
hr_dev.gold.dim_employee
hr_dev.gold.dim_department
hr_dev.gold.fact_payroll
hr_dev.gold.mart_hr_headcount_summary
hr_dev.snapshots.snp_employee
```

---

## 2. Project Structure

```text
hr_analytics_dbt_databricks/
├── README.md
├── dbt_project.yml
├── packages.yml
├── profiles.yml.example
├── .gitignore
├── sql/
│   └── 00_create_catalogs_and_schemas.sql
├── seeds/
│   ├── _seeds.yml
│   ├── sample_employee_raw.csv
│   ├── sample_department_raw.csv
│   ├── sample_job_raw.csv
│   ├── sample_payroll_raw.csv
│   └── transformation_rules.csv
├── macros/
│   ├── generate_schema_name.sql
│   ├── audit_columns.sql
│   ├── surrogate_key.sql
│   ├── apply_rules.sql
│   └── generic_tests.sql
├── models/
│   ├── sources/
│   │   └── _sources.yml
│   ├── staging/
│   │   ├── _staging.yml
│   │   ├── stg_workday_employee.sql
│   │   ├── stg_workday_department.sql
│   │   ├── stg_workday_job.sql
│   │   └── stg_dayforce_payroll.sql
│   ├── silver/
│   │   ├── _silver.yml
│   │   ├── silver_employee.sql
│   │   ├── silver_department.sql
│   │   ├── silver_job.sql
│   │   └── silver_payroll.sql
│   └── gold/
│       ├── _gold.yml
│       ├── dim_employee.sql
│       ├── dim_department.sql
│       ├── fact_payroll.sql
│       ├── mart_hr_headcount_summary.sql
│       └── exposures.yml
├── snapshots/
│   └── snp_employee.sql
├── tests/
│   ├── assert_payroll_amounts_are_valid.sql
│   └── assert_employee_department_relationship.sql
└── analyses/
    └── employee_turnover_analysis.sql
```

---

## 3. Dynamic Ruleset Design

The dynamic rules are stored in this Delta table:

```sql
hr_dev.config.transformation_rules
```

For this demo, the rules table is loaded from this seed:

```text
seeds/transformation_rules.csv
```

In real production, business/data governance users can maintain the UC Delta rules table directly through a governed workflow.

The dbt model stays static:

```text
models/silver/silver_employee.sql
```

But the transformation logic is dynamic:

```sql
{{ apply_rules(
    rule_set_name=var('rule_set_name'),
    target_model='silver_employee',
    source_alias='src'
) }}
```

This means:

| Concept | Static or Dynamic? |
|---|---|
| dbt model file | Static |
| dbt DAG node | Static |
| target UC table | Static |
| rule expressions | Dynamic |
| selected ruleset/version | Dynamic |
| generated SQL columns | Dynamic |

---

## 4. How to Run Locally with dbt Core

Install adapter:

```bash
pip install dbt-databricks
```

Install packages:

```bash
dbt deps
```

Validate connection:

```bash
dbt debug --profiles-dir .
```

Create catalogs/schemas in Databricks SQL Warehouse:

```sql
-- Run sql/00_create_catalogs_and_schemas.sql in Databricks SQL
```

Load sample raw and rules data:

```bash
dbt seed --full-refresh --profiles-dir . --target dev
```

Run everything:

```bash
dbt build --profiles-dir . --target dev --vars '{"rule_set_name": "hr_standardization_v1", "rules_effective_date": "2026-05-05"}'
```

Run snapshots only:

```bash
dbt snapshot --profiles-dir . --target dev
```

Generate docs:

```bash
dbt docs generate --profiles-dir . --target dev
```

Serve docs locally:

```bash
dbt docs serve --profiles-dir . --target dev
```

---

## 5. How to Use in dbt Cloud

In dbt Cloud:

1. Connect this GitHub repository.
2. Create Databricks connection using a SQL Warehouse.
3. Create environments:
   - Dev catalog: `hr_dev`
   - QA catalog: `hr_qa`
   - Prod catalog: `hr_prod`
4. Set job command:

```bash
dbt deps
dbt seed --full-refresh
dbt build --vars '{"rule_set_name": "hr_standardization_v1", "rules_effective_date": "2026-05-05"}'
dbt snapshot
```

For production, you may skip `dbt seed` for raw data and only use real bronze tables populated by ingestion pipelines.

---

## 6. Interview Explanation

Use this answer:

> “For our HR analytics lakehouse, we used GitHub as the source code repository and dbt Cloud as the transformation and deployment framework. We did not use Databricks Asset Bundles for this project. The project followed medallion architecture with bronze, silver, and gold layers. In Unity Catalog, catalogs represented environment and domain, such as `hr_dev`, `hr_qa`, and `hr_prod`; schemas represented medallion layers, such as `bronze`, `silver`, and `gold`; and each dbt model created a governed Delta table or view.  
>
> For dynamic transformation rules, we designed a governed `config.transformation_rules` Delta table in Unity Catalog. dbt exposed that table as a seed/source, and Jinja macros used `run_query` to read active rules and generate transformation SQL during compilation. This allowed business rules to be metadata-driven while preserving static dbt models, clear DAG lineage, tests, documentation, and CI/CD review.”

---

## 7. Production Hardening Ideas

For a real enterprise project:

- Replace sample seeds with real bronze Delta tables from Auto Loader, ADF, APIs, or CDC.
- Maintain `config.transformation_rules` through a governed UI/workflow.
- Add approval workflow for rule changes.
- Add row-level security and column masks for PII fields like email and salary.
- Use service principal authentication for dbt Cloud jobs.
- Use job-specific SQL warehouses for production dbt runs.
- Add `OPTIMIZE`, liquid clustering, and statistics maintenance based on table size and query patterns.
- Add UC grants by Azure Entra ID groups.
- Add audit reporting from Unity Catalog system tables.
