# Java Dependency Analysis

A Java static analysis tool developed for SWEN438 at Victoria University of Wellington. The program analyses compiled Java classes to identify dependencies, examine software structure, and detect potential architectural issues.

## How It Works

The program uses ASM to analyse Java bytecode and construct dependency graphs between classes. It identifies relationships such as inheritance, method calls, field references, and interface implementations.

These relationships can be combined into package-level dependency graphs to examine the overall structure of a Java application.

The project also includes functionality to:

- Detect circular package dependencies using strongly connected components.
- Calculate class abstractness metrics.
- Identify test classes.
- Generate Mermaid diagrams to visualise package dependencies.

This allows the tool to be used to inspect the structure of compiled Java projects and identify dependencies that may make software harder to maintain.

## Example Output

The program can generate a Mermaid diagram showing dependencies between packages in a Java project.

An example generated from the included test project is available in `examples/output.mmd`.

## Requirements

- Java 17
- Apache Maven

## Run

Build the included example project:

```bash
mvn -f src/test/resources/testproject1/pom.xml clean package
```

Build the dependency analyser:

```bash
mvn clean package
```

Generate the dependency classpath:

```bash
mvn dependency:build-classpath -Dmdep.outputFile=classpath.txt
```

Run the package dependency visualiser (Windows Git Bash):

```bash
java -cp "target/classes;$(cat classpath.txt)" PackageDependencyGraphVisualiser "src/test/resources/testproject1/target/classes" "examples/output.mmd"
```

The visualiser analyses the compiled classes and writes the resulting package dependency graph to the specified Mermaid file.

Run the tests:

```bash
mvn test
```