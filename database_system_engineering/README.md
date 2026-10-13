# Database System Engineering

A PostgreSQL database project modelling bank robberies, including information about banks, robbers, robberies, and related activities.

## Features

- Relational database design with primary and foreign keys
- Data integrity constraints
- Importing and transforming data from external files
- SQL queries using joins, subqueries, aggregation, and views

## Project Structure

- `schema.sql` — Creates the database tables and constraints
- `load_data.sql` — Imports and populates the database
- `queries.sql` — Contains SQL queries for analysing the data
- `data/` — Contains the source data files

## Running the Project

Requires PostgreSQL and the `psql` command-line tool.

1. Create a database:

   ```bash
   createdb -U postgres bank_robberies
   ```

2. From the project directory, run:

   ```bash
   psql -U postgres -d bank_robberies -v ON_ERROR_STOP=1 -f schema.sql
   psql -U postgres -d bank_robberies -v ON_ERROR_STOP=1 -f load_data.sql
   psql -U postgres -d bank_robberies -v ON_ERROR_STOP=1 -f queries.sql
   ```

Replace `postgres` with your PostgreSQL username if different. The commands assume your server is available on the default local connection.

The scripts should be run in the order shown, starting with an empty database.