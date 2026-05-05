-- Run this in a Databricks SQL Warehouse before executing dbt.
-- Use only the catalogs you need. In production, create/grant through your platform/admin process.

CREATE CATALOG IF NOT EXISTS hr_dev;
CREATE CATALOG IF NOT EXISTS hr_qa;
CREATE CATALOG IF NOT EXISTS hr_prod;

CREATE SCHEMA IF NOT EXISTS hr_dev.bronze;
CREATE SCHEMA IF NOT EXISTS hr_dev.config;
CREATE SCHEMA IF NOT EXISTS hr_dev.silver;
CREATE SCHEMA IF NOT EXISTS hr_dev.gold;
CREATE SCHEMA IF NOT EXISTS hr_dev.snapshots;

CREATE SCHEMA IF NOT EXISTS hr_qa.bronze;
CREATE SCHEMA IF NOT EXISTS hr_qa.config;
CREATE SCHEMA IF NOT EXISTS hr_qa.silver;
CREATE SCHEMA IF NOT EXISTS hr_qa.gold;
CREATE SCHEMA IF NOT EXISTS hr_qa.snapshots;

CREATE SCHEMA IF NOT EXISTS hr_prod.bronze;
CREATE SCHEMA IF NOT EXISTS hr_prod.config;
CREATE SCHEMA IF NOT EXISTS hr_prod.silver;
CREATE SCHEMA IF NOT EXISTS hr_prod.gold;
CREATE SCHEMA IF NOT EXISTS hr_prod.snapshots;
