import argparse
import time

from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from pyspark.ml.feature import VectorAssembler, MinMaxScaler, PCA
from pyspark.ml.classification import MultilayerPerceptronClassifier, LogisticRegression, NaiveBayes, DecisionTreeClassifier
from pyspark.ml.evaluation import MulticlassClassificationEvaluator


# Command-line arguments
parser = argparse.ArgumentParser(description="EMNIST classification using Apache Spark")
parser.add_argument("input_file")
parser.add_argument("--model", choices=["logistic", "tree", "naive_bayes", "mlp"], default="logistic")
parser.add_argument("--features", choices=["original", "scaled", "pca"], default="scaled")

args = parser.parse_args()

if args.model == "naive_bayes" and args.features == "pca":
    parser.error("Naive Bayes cannot use PCA features containing negative values.")

num_pca_components = 50
start_time = time.time()

# Initialise Spark
spark = SparkSession.builder.appName("EMNIST").getOrCreate()
spark.sparkContext.setLogLevel("ERROR")

try:
    # Load EMNIST CSV
    dataframe = spark.read.csv(args.input_file, header=False, inferSchema=True)

    # Rename columns
    features = [f"f{i}" for i in range(1, len(dataframe.columns))]
    dataframe = dataframe.toDF("label", *features)

    # Convert EMNIST Letters labels from 1-26 to 0-25
    dataframe = dataframe.withColumn("indexedLabel", col("label").cast("double") - 1.0)

    # Assemble features
    assembler = VectorAssembler(inputCols=features, outputCol="features")
    dataframe = assembler.transform(dataframe)

    # Split data before preprocessing
    train, test = dataframe.randomSplit([0.7, 0.3], seed=1)

    feature_col = "features"

    # Apply selected feature representation
    if args.features == "scaled":
        scaler = MinMaxScaler(inputCol="features", outputCol="scaledFeatures")
        scaler_model = scaler.fit(train)
        train = scaler_model.transform(train)
        test = scaler_model.transform(test)
        feature_col = "scaledFeatures"

    elif args.features == "pca":
        pca = PCA(k=num_pca_components, inputCol="features", outputCol="pcaFeatures")
        pca_model = pca.fit(train)
        train = pca_model.transform(train)
        test = pca_model.transform(test)
        feature_col = "pcaFeatures"

    # Select classifier
    if args.model == "logistic":
        algorithm = LogisticRegression(labelCol="indexedLabel", featuresCol=feature_col)

    elif args.model == "tree":
        algorithm = DecisionTreeClassifier(labelCol="indexedLabel", featuresCol=feature_col)

    elif args.model == "naive_bayes":
        algorithm = NaiveBayes(labelCol="indexedLabel", featuresCol=feature_col)

    elif args.model == "mlp":
        input_size = (num_pca_components if args.features == "pca" else len(features))
        algorithm = MultilayerPerceptronClassifier(labelCol="indexedLabel", featuresCol=feature_col, layers=[input_size, 128, 64, 26], seed=42)

    # Train model
    train_start = time.time()
    model = algorithm.fit(train)

    # Make predictions
    predictions_train = model.transform(train)
    predictions_test = model.transform(test)

    # Evaluate accuracy
    evaluator = MulticlassClassificationEvaluator(labelCol="indexedLabel", predictionCol="prediction", metricName="accuracy")

    accuracy_train = evaluator.evaluate(predictions_train)
    accuracy_test = evaluator.evaluate(predictions_test)

    evaluation_time = time.time() - train_start
    total_time = time.time() - start_time

    # Print results
    print("\n===================")
    print(f"Model: {args.model}")
    print(f"Features: {args.features}")
    print(f"Training accuracy: {accuracy_train:.4f}")
    print(f"Testing accuracy: {accuracy_test:.4f}")
    print(f"Training and evaluation time: {evaluation_time:.4f}s")
    print(f"Total time: {total_time:.4f}s")

finally:
    spark.stop()
