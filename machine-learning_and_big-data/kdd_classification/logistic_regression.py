#!/usr/bin/python3
import sys
import time
import numpy as np
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.evaluation import MulticlassClassificationEvaluator

total_start_time = time.time()

# Check for correct number of arguments
if len(sys.argv) != 2:
    print("Usage: spark-submit logistic_regression.py <input_file>", file=sys.stderr)
    sys.exit(1)

input_file = sys.argv[1]

# Initialize Spark session
spark = SparkSession.builder.appName("LogisticRegression").getOrCreate()
spark.sparkContext.setLogLevel("ERROR")

# Load data
data = spark.read.csv(input_file, header=False, inferSchema=True)

# Rename columns
features = [f"f{i}" for i in range(1, 42)]
dataframe = data.toDF(*features, "label")

# Convert labels to numeric values
dataframe = dataframe.withColumn("indexedLabel", when(col("label") == "normal", 0.0).when(col("label") == "anomaly", 1.0))

# Assemble features
assembler = VectorAssembler(inputCols=features, outputCol="features")
dataframe = assembler.transform(dataframe)

accuracies_train = []
accuracies_test = []
times = []

# Evaluate over 10 seeds
for seed in range(10):
    print("\n===================")
    print(f"Seed: {seed}\n")

    start_time = time.time()

    # Split data based on different seeds
    train, test = dataframe.randomSplit([0.7, 0.3], seed=seed)
    
    # Create logistic regression model and train on the training data
    lr = LogisticRegression(labelCol="indexedLabel", featuresCol="features")
    model = lr.fit(train)

    # Make predictions on train and test sets
    predictions_train = model.transform(train)
    predictions_test = model.transform(test)

    # Calculate and record the accuracy
    evaluator = MulticlassClassificationEvaluator(labelCol="indexedLabel", predictionCol="prediction", metricName="accuracy")

    accuracy_train = evaluator.evaluate(predictions_train)
    accuracy_test = evaluator.evaluate(predictions_test)

    accuracies_train.append(accuracy_train)
    accuracies_test.append(accuracy_test)

    elapsed_time = time.time() - start_time
    times.append(elapsed_time)

    print(f"Training accuracy: {accuracy_train:.4f}")
    print(f"Testing accuracy: {accuracy_test:.4f}")
    print(f"Time: {elapsed_time:.4f}")

total_elapsed_time = time.time() - total_start_time

training_data_results = np.array(accuracies_train)
testing_data_results = np.array(accuracies_test)
times_np = np.array(times)

print("\n===================")
print(f"Results:\n\n")
print(f"Max Training: {training_data_results.max():.4f}")
print(f"Min Training: {training_data_results.min():.4f}")
print(f"Average Training: {training_data_results.mean():.4f}")
print(f"Std Training: {training_data_results.std():.4f}\n")
print(f"Max Testing: {testing_data_results.max():.4f}")
print(f"Min Testing: {testing_data_results.min():.4f}")
print(f"Average Testing: {testing_data_results.mean():.4f}")
print(f"Std Testing: {testing_data_results.std():.4f}\n\n")
print(f"Average time per iteration: {times_np.mean():.4f}")
print(f"Total time: {total_elapsed_time:.4f}")

spark.stop()
