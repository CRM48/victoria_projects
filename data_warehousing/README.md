# Data Warehousing and SQL Analysis

PostgreSQL data mart for bookstore sales, with sales aggregation, `ROLLUP`, window functions and query performance comparisons. Based on SWEN432 coursework.

## Purpose

This project demonstrates the use of SQL for data warehousing, sales analysis and query optimisation. It covers creating a data mart from a relational database, analysing sales data using aggregation and window functions, and comparing query execution strategies using `EXPLAIN ANALYZE`.

## Requirements

- PostgreSQL

## Run

Create an empty database and load the source dataset:

```bash
createdb bookstore
psql -d bookstore -f data/bookstore.sql
```

Then run the SQL files **in order** (from the project folder):

```bash
psql -d bookstore -f sql/01_create_data_mart.sql
psql -d bookstore -f sql/02_sales_analysis.sql
psql -d bookstore -f sql/03_query_performance.sql
psql -d bookstore -f sql/04_window_functions.sql
```

Or paste each file into pgAdmin Query Tool. Run the setup files on a fresh database; don't repeat the `CREATE TABLE` and `CREATE MATERIALIZED VIEW` statements without dropping those objects first.

`EXPLAIN ANALYZE` runs each query and displays its execution plan/timings. Timings depend on the machine, cache and PostgreSQL version.