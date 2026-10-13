# Neural Network Distribution Mapping

A project exploring the use of neural networks to transform data between Gaussian and uniform distributions. Three models were implemented using PyTorch, with different architectures and training approaches.

## Models

### 1. Gaussian to Uniform
- Maps 2D Gaussian data to a 2D uniform distribution.
- Uses a fully connected neural network with two hidden layers.
- Trained using Maximum Mean Discrepancy (MMD) loss to match the target distribution.
- Includes experiments comparing L1 and L2 regularisation.

### 2. Uniform to Gaussian
- Maps 2D uniform data back to a 2D Gaussian distribution.
- Uses a larger network with three hidden layers.
- Trained using supervised learning and Mean Squared Error (MSE), with paired data generated using the first model.

### 3. 1D Uniform to 2D Gaussian
- Attempts to map one-dimensional uniform data to a two-dimensional Gaussian distribution.
- Uses MMD loss to compare predicted and target distributions.
- The model was unsuccessful, producing outputs concentrated along a curve rather than a full 2D Gaussian distribution.

## Running the Project

The project is contained in `distribution_mapping.ipynb` and was developed using Google Colab.

1. Open the notebook in Google Colab.
2. Select **Runtime → Change runtime type → GPU**.
3. Run all cells to train the models and generate the visualisations.

The notebook uses PyTorch, NumPy and Matplotlib. Each model trains for 5,000 iterations, printing its loss every 500 iterations and generating plots comparing the input and output distributions.

Model parameters, including the learning rate, batch size, activation functions and regularisation, can be adjusted in the notebook.

## Report

See [report.pdf](report.pdf) for the full methodology, experiments and results.