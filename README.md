# Victoria University Portfolio

This repository contains selected projects from my postgraduate studies at Victoria University of Wellington:

- Master of Computer Science | Victoria University of Wellington (2025–2027)
- Completed as part of a double Master's degree with ZHAW School of Engineering, Switzerland.

## Projects

- **[Cancer Visualisation](cancer_visualisation/)** – An interactive website for exploring historical cancer trends, mortality statistics and comparisons between populations.
- **[Data Warehousing](data_warehousing/)** – A PostgreSQL data warehouse for analysing bookstore sales using analytical SQL, OLAP operations and query performance evaluation.
- **[Database System Engineering](database_system_engineering/)** – A relational database built around a fictional bank robbery dataset, demonstrating database design, complex SQL queries and data integrity.
- **[Graph Database Analysis](graph_database_analysis/)** – A Neo4j graph database for exploring relationships between movies, actors, directors and users, including graph centrality analysis.
- **[Java Dependency Analysis](java_dependency_analysis/)** – A static analysis tool that examines compiled Java applications to identify class dependencies, circular dependencies and software architecture relationships.
- **[Java Fuzz Testing](java_fuzz_testing/)** – An automated testing tool that explores a game using breadth-first search and Java bytecode instrumentation to identify runtime errors.
- **[Machine Learning and Big Data](machine-learning_and_big-data/)** – A collection of machine learning experiments covering dimensionality reduction, classification and distributed processing with Apache Spark.
- **[Multi-Paradigm Stack Interpreter](multi-paradigm_stack_interpreter/)** – A stack-based interpreter implemented in Ruby, Haskell and Prolog to explore different programming paradigms.
- **[Neural Networks](neural_networks/)** – A collection of deep learning experiments exploring distribution mapping, autoencoders, variational autoencoders and neural differential equations.

## Project Details

### Cancer Visualisation

- An interactive website designed to explore and visualise cancer-related statistics, including historical trends, mortality rates and comparisons between populations.
- Developed using HTML, CSS, JavaScript and D3.js, with data loaded from CSV and JSON files.
- Contains three main visualisation sections:
  - **History:** Explores historical cancer data and trends.
  - **Mortality:** Visualises cancer mortality statistics.
  - **Comparison:** Allows different cancer-related statistics and populations to be compared.
- Uses D3.js to convert datasets into interactive visualisations, helping users explore patterns that may be difficult to interpret from raw data.
- Demonstrates frontend development, data visualisation, data processing and the presentation of statistical information through an interactive interface.
- The website can be run locally using a simple HTTP server, without requiring a database or backend application.
- Instructions for running the website are provided in the project's README.

### Data Warehousing

- A collection of SQL scripts exploring the design and analysis of a data warehouse using PostgreSQL.
- Uses a bookstore sales dataset to build a data mart and perform analytical queries.
- The project covers several areas of data warehousing:
  - **Data Mart Creation:** Structures sales information for analytical queries.
  - **Sales Analysis:** Uses SQL queries to examine sales data and identify patterns.
  - **OLAP Operations:** Uses operations such as `ROLLUP` to aggregate information at different levels.
  - **Query Performance:** Uses `EXPLAIN ANALYZE` to investigate and compare SQL query execution.
  - **Window Functions:** Performs calculations and comparisons across related groups of rows.
- Demonstrates the distinction between transactional databases and databases designed for analytical workloads.
- Also explores how SQL can be used for more advanced analysis, beyond basic data retrieval.
- The individual SQL scripts are organised in the order they should be executed, with setup and usage instructions in the README.

### Database System Engineering

- A relational database project exploring database design, implementation and querying using SQL.
- Based on a fictional bank robbery dataset containing information about banks, robbers, robberies, skills, accomplices and related records.
- The database schema includes primary and foreign keys, composite keys, constraints and many-to-many relationships to maintain data consistency.
- The project includes SQL queries demonstrating different techniques for retrieving and analysing data:
  - Joins across multiple related tables, including outer joins.
  - Aggregation and grouping using functions such as `COUNT`, `SUM` and `HAVING`.
  - Nested queries and subqueries.
  - Views and derived tables.
  - Alternative SQL approaches to producing the same results.
- Also explores database integrity and relationships between tables, including the use of constraints and cascading operations.
- Demonstrates relational database design, data integrity, SQL querying and different approaches to solving database problems.
- The README contains instructions for creating the database and executing the SQL scripts.

### Graph Database Analysis

- A graph database project using Neo4j and Cypher to analyse a dataset of movies, directors, actors and user ratings.
- The project imports data from CSV files and constructs a graph of nodes and relationships representing the movie dataset.
- Uses Cypher queries to explore relationships between entities, retrieve information and analyse patterns in the graph.
- The project is divided into three main parts:
  - **Data Import:** Creates nodes and relationships from the original CSV datasets.
  - **Graph Queries:** Uses Cypher to retrieve and analyse connections between movies, actors, directors and users.
  - **Graph Algorithms:** Uses Neo4j Graph Data Science to analyse the structure and importance of nodes.
- Graph algorithms include degree, closeness and betweenness centrality, providing different measures of how connected or important a node is within the graph.
- Demonstrates graph data modelling, Cypher querying and graph-based analysis, as an alternative to traditional relational database approaches.
- The README explains how to import the data, execute the queries and run the graph algorithms.

### Java Dependency Analysis

- A Java static analysis tool designed to examine the structure and dependencies of compiled Java applications.
- Uses the ASM library to inspect Java bytecode and identify relationships between classes, without requiring access to the original source code.
- Identifies several types of class dependencies, including inheritance, method calls, field references and interface implementations.
- These relationships are used to construct class-level dependency graphs, which can then be combined into package-level graphs.
- The project also includes functionality to:
  - Detect circular dependencies using strongly connected components.
  - Calculate class abstractness metrics.
  - Identify test classes.
  - Generate Mermaid diagrams showing dependencies between packages.
- The purpose is to provide information about the structure of Java applications and identify relationships that may contribute to tightly coupled or difficult-to-maintain software.
- Demonstrates static program analysis, graph algorithms, Java bytecode processing and software architecture analysis.
- Includes a small example Java project for testing the analyser, with build and usage instructions in the README.

### Java Fuzz Testing

- A Java fuzzing tool designed to explore a Chip's Challenge game and automatically identify runtime errors.
- Uses breadth-first search (BFS) to systematically explore the game map and investigate different movement paths.
- The fuzzer records visited locations, movement paths and detected errors to avoid unnecessary repeated exploration.
- When a key is collected, the search restarts from that location, allowing previously inaccessible areas to be explored.
- Unlike a traditional game-solving algorithm, the search continues after reaching the finishing location, allowing the program to identify multiple errors throughout the map.
- Uses Java bytecode instrumentation through ASM and Java agents to retrieve the player's coordinates and collected keys at runtime.
- This information is accessed without modifying the original game implementation.
- Detected exceptions and their locations are recorded in a CSV file, while an SVG visualisation displays the game map.
- Demonstrates automated software testing, BFS, runtime instrumentation and Java application internals.
- The README explains the implementation and how to build and run the fuzzer using dynamic Java agent attachment.

### Machine Learning and Big Data

- A collection of machine learning experiments exploring dimensionality reduction, classification and distributed data processing.
- Uses Python and Apache Spark to investigate how different algorithms process and classify large datasets.
- The project is divided into three main areas:

**Dimensionality Reduction**
- Explores techniques for reducing the number of features in high-dimensional datasets while preserving useful information.
- Includes Principal Component Analysis (PCA), explained variance analysis, Isomap and t-SNE.
- Uses image datasets such as MNIST to investigate how high-dimensional image data can be represented in fewer dimensions.
- Demonstrates the differences between linear and nonlinear dimensionality reduction techniques.

**KDD Classification**
- Uses Apache Spark MLlib to classify data from the KDD dataset.
- Implements classification algorithms including decision trees and logistic regression.
- Explores data preparation, model training and the evaluation of classification performance using distributed machine learning tools.

**EMNIST Classification**
- Uses Apache Spark to train and evaluate machine learning models on the EMNIST handwritten character dataset.
- Compares different classification approaches, including decision trees, Naive Bayes, logistic regression and multilayer perceptrons.
- Explores how data scaling and dimensionality reduction influence model performance.
- Measures classification accuracy and execution time to compare different model configurations.

- Overall, this collection demonstrates machine learning, dimensionality reduction, model evaluation and the use of Apache Spark for processing larger datasets.
- Each section can be run independently, with instructions and dependencies described in the README.

### Multi-Paradigm Stack Interpreter

- A stack-based interpreter implemented in three different programming languages: Ruby, Haskell and Prolog.
- The purpose is to explore how the same programming problem can be approached using different programming paradigms.
- The interpreter processes commands and values using a stack, performing operations based on the supplied instructions.
- Functionality includes:
  - Arithmetic, comparison and Boolean operations.
  - Stack manipulation, including duplication, swapping and removing values.
  - Strings, vectors and matrices.
  - Conditional operations and expression evaluation.
  - More advanced functionality such as lambda expressions.
- Each implementation approaches the problem differently:
  - **Ruby:** Uses a dynamically typed, object-oriented and imperative approach.
  - **Haskell:** Uses functional programming concepts such as recursion, pattern matching and immutable data.
  - **Prolog:** Uses logic programming, unification and declarative rules.
- The project demonstrates how language paradigms influence program structure, state management and the implementation of an interpreter.
- Also provides experience with parsing instructions, evaluating expressions and implementing similar functionality across different languages.
- Each implementation has its own execution instructions in the README.

### Neural Networks

- A collection of deep learning experiments exploring neural network architectures, representation learning and generative modelling.
- Implemented primarily in Python using PyTorch, with Jupyter notebooks for training, testing and visualising results.
- The project contains three main areas:

**Distribution Mapping**
- Uses neural networks to learn transformations between probability distributions.
- Includes a model that transforms two-dimensional Gaussian data into a two-dimensional uniform distribution.
- Explores distribution-based loss functions, including Maximum Mean Discrepancy (MMD), to compare the generated and target distributions.
- Demonstrates how neural networks can learn mappings between continuous data distributions rather than simply predicting individual values.

**Autoencoders**
- Explores neural networks that learn compressed representations of input data and reconstruct the original inputs.
- Includes experiments with autoencoders and variational autoencoders (VAEs).
- Investigates how an encoder and decoder can learn useful representations of data, and how probabilistic latent spaces can be used for generation.
- Demonstrates representation learning, reconstruction loss and generative neural network architectures.

**Neural Differential Equations**
- Explores continuous transformations between data distributions using neural differential equations.
- Includes experiments involving the transformation of Gaussian distributions and image distributions, such as cats and dogs.
- Investigates ordinary differential equation (ODE) approaches and stochastic sampling methods.
- Demonstrates the application of differential equations, neural networks and numerical methods to generative modelling.

- Overall, the project demonstrates neural network design, model training, loss functions, generative modelling and experimental evaluation.
- The notebooks contain the implementations, experiments and visualisations, with further details in the project README.