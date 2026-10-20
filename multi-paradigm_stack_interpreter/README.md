# Multi-Paradigm Stack Interpreter

A stack-based programming language implemented in Ruby, Haskell and Prolog as part of Advanced Programming Languages coursework at Victoria University of Wellington in 2025.

The project explores how different programming paradigms approach the same problem, including parsing, stack manipulation and expression evaluation.

## Implementations

### Ruby

- Object-oriented implementation using classes for input processing and stack execution.
- Supports arithmetic, comparisons, stack manipulation and more advanced expressions.

### Haskell

- Functional implementation using recursion, pattern matching and immutable data.
- Processes stack operations through functions rather than modifying shared state.

### Prolog

- Logic-programming implementation using predicates, recursion and pattern matching.
- Evaluates stack operations through declarative rules and logical relationships.

## Requirements

- Ruby
- GHC (Haskell)
- SWI-Prolog

Only the language required for the chosen implementation needs to be installed.

## How to Run

Each implementation can be run independently from its respective folder.

**Ruby**

```bash
ruby main.rb
```

**Haskell**

```bash
runghc Main.hs
```

**Prolog**

```bash
swipl -s main.pl
```

Replace the filenames with the relevant entry-point files if they differ.

## Usage

Each implementation reads and evaluates instructions for the stack-based language.

The interpreter supports operations such as:

- Pushing values onto the stack and manipulating existing values.
- Performing arithmetic, comparison and Boolean operations.
- Working with strings, vectors and matrices.
- Evaluating conditional expressions and more advanced operations.

The three implementations demonstrate different approaches to processing the same stack-based instructions.