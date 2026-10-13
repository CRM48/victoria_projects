# Graph Database Analysis

Neo4j graph database exploring relationships between movies, actors, directors and users using Cypher queries and graph algorithms. Based on SWEN432 coursework.

## Purpose

This project demonstrates the use of graph databases to store, query and analyse connected data. It covers importing and modelling data in Neo4j, querying relationships using Cypher, and applying graph algorithms to identify important nodes within a network.

It also explores degree, closeness and betweenness centrality using the Neo4j Graph Data Science library.

## Requirements

- Neo4j with local CSV import enabled
- Neo4j Graph Data Science (GDS) plugin

## Run

1. Create a new, empty Neo4j database (Neo4j Desktop is recommended).
2. Copy the CSV files from `data/` into the database's `import` directory.
3. In Neo4j Browser, run the statements in `cypher/01_import.cypher` **in order**, one at a time.
4. Run `cypher/02_queries.cypher` to query movie and user relationships.
5. Run `cypher/03_graph_algorithms.cypher` in order to create graph projections and execute the centrality algorithms.