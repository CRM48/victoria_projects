# Victoria University Portfolio

This repository contains selected projects from my postgraduate studies at Victoria University of Wellington:

- Master of Computer Science | Victoria University of Wellington (2025–2027)
- Completed as part of a double Master's degree with ZHAW School of Engineering, Switzerland.

## Projects

- **[Java Dependency Analysis](java_dependency_analysis/)** – Static analysis of Java applications and their software dependencies.
- **[Java Fuzz Testing](java_fuzz_testing/)** – Automated game testing using search algorithms and Java bytecode instrumentation.
- **[Machine Learning and Big Data](machine-learning_and_big-data/)** – Machine learning experiments and distributed data processing using Apache Spark.
- **[Neural Networks](neural_networks/)** – Deep learning experiments exploring neural network architectures and generative modelling.
- **[Multi-Paradigm Stack Interpreter](multi-paradigm_stack_interpreter/)** – A stack-based interpreter implemented in Ruby, Haskell and Prolog.
- **[Cancer Visualisation](cancer_visualization/)** – An interactive website for exploring and comparing cancer statistics.
- **[Graph Database Analysis](graph_database_analysis/)** – Graph database queries and centrality analysis using Neo4j.
- **[Data Warehousing](data_warehousing/)** – Analytical SQL and data warehousing using PostgreSQL.
- **[Database System Engineering](database_system_engineering/)** – Relational database design, complex SQL queries and data integrity.

## Project Details

### Java Dependency Analysis

- A Java static analysis tool that examines compiled applications using the ASM bytecode library, without requiring the original source code.
- Identifies class dependencies through inheritance, method calls, field references and interface implementations.
- Constructs class and package dependency graphs, detects circular dependencies and generates Mermaid diagrams.
- Demonstrates static program analysis, graph algorithms, Java bytecode processing and software architecture analysis.

### Java Fuzz Testing

- An automated testing tool designed to explore a Chip's Challenge game and identify runtime errors.
- Uses breadth-first search (BFS) to explore movement paths, track visited locations and discover errors throughout the game.
- Uses Java bytecode instrumentation and Java agents to inspect the game's internal state without modifying its source code.
- Records detected exceptions in CSV files and generates an SVG visualisation of the game map.

### Machine Learning and Big Data

- A collection of Python and Apache Spark projects exploring machine learning algorithms and distributed data processing.
- Implements dimensionality reduction techniques including PCA, Isomap and t-SNE, using datasets such as MNIST.
- Uses Spark MLlib for KDD classification and EMNIST handwritten character recognition, comparing algorithms such as logistic regression, decision trees, Naive Bayes and multilayer perceptrons.
- Evaluates model accuracy, execution time and the impact of preprocessing and dimensionality reduction.

### Neural Networks

- A collection of Python and PyTorch experiments exploring deep learning, representation learning and generative modelling.
- Uses neural networks to transform probability distributions, including Gaussian-to-uniform mappings with Maximum Mean Discrepancy (MMD).
- Implements autoencoders and variational autoencoders (VAEs) to explore data compression, reconstruction and generative representations.
- Investigates neural differential equations and stochastic sampling methods for transforming continuous and image distributions.

### Multi-Paradigm Stack Interpreter

- A stack-based interpreter implemented in Ruby, Haskell and Prolog to explore different programming paradigms.
- Supports arithmetic, comparisons, Boolean operations, stack manipulation, strings, vectors, matrices and conditional expressions.
- Includes more advanced operations such as lambda expressions and expression evaluation.
- Demonstrates how object-oriented, functional and logic programming approaches differ when solving the same problem.

### Cancer Visualisation

- An interactive website that explores historical cancer trends, mortality statistics and comparisons between populations.
- Developed using HTML, CSS, JavaScript and D3.js, with data loaded from CSV and JSON files.
- Contains three main sections: historical trends, mortality analysis and comparisons between cancer-related statistics.
- Demonstrates front-end development, data processing and interactive data visualisation.

### Graph Database Analysis

- A Neo4j graph database project analysing relationships between movies, actors, directors and user ratings.
- Imports CSV datasets to construct a graph of interconnected nodes and relationships.
- Uses Cypher queries to retrieve information, explore relationships and investigate patterns within the graph.
- Applies Neo4j Graph Data Science algorithms, including degree, closeness and betweenness centrality, to analyse node importance.

### Data Warehousing

- A PostgreSQL project exploring the design and analysis of a data warehouse using a bookstore sales dataset.
- Creates a data mart and uses SQL queries to analyse sales information and identify patterns.
- Implements analytical SQL techniques including OLAP operations, `ROLLUP`, aggregations and window functions.
- Uses `EXPLAIN ANALYZE` to investigate query performance and compare different execution approaches.

### Database System Engineering

- A relational database project based on a fictional bank robbery dataset containing banks, robberies, robbers, skills and related information.
- Designs a relational schema using primary keys, foreign keys, composite keys and constraints to maintain data integrity.
- Implements complex SQL queries involving joins, aggregations, subqueries, views and alternative approaches to retrieving the same results.
- Demonstrates relational database design, SQL querying, data integrity and database relationships.

---

Each project folder contains its source code and a separate README with further details on the implementation, setup and usage.