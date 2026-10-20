# Machine Learning and Big Data

A collection of Python and Apache Spark projects developed at Victoria University of Wellington in 2025. The projects explore machine learning, dimensionality reduction, classification and distributed data processing.

## Requirements

- Python 3
- NumPy, Matplotlib and scikit-learn
- PySpark and Java JDK (for Spark projects)

## Projects

### Dimensionality Reduction

- Implements PCA, Isomap and t-SNE to reduce the dimensions of datasets such as MNIST.
- Compares linear and nonlinear approaches to dimensionality reduction.
- Produces visualisations and evaluates how well information is preserved.

### KDD Classification

- Uses Apache Spark MLlib to classify data from the KDD dataset.
- Implements algorithms including decision trees and logistic regression.
- Explores data preprocessing, model training and classification performance.

### EMNIST Classification

- Uses Apache Spark to classify handwritten characters from the EMNIST dataset.
- Compares decision trees, Naive Bayes, logistic regression and multilayer perceptrons.
- Evaluates model accuracy, execution time and the effects of preprocessing.

## Setup and Usage

Create and activate a Python virtual environment:

```bash
python -m venv .venv
source .venv/Scripts/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Each project can be run independently. For example:

```bash
python dimensionality_reduction/pca.py
```

The KDD and EMNIST projects require their respective datasets and Apache Spark.

See the individual project files for further details on the experiments and available configurations.