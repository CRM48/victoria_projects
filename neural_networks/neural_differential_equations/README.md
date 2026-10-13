# Neural Differential Equations for Distribution Mapping

A project exploring the use of neural networks and differential equations to transform data between distributions. Two approaches were implemented using PyTorch: Ordinary Differential Equations (ODEs) and an experimental stochastic method based on Stochastic Differential Equations (SDEs).

## Models

### 1. Cats to Dogs (ODE)
- Maps samples from one 2D uniform distribution to another.
- Uses a neural network to learn a velocity field between the distributions.
- Applies backward Euler integration to transform the samples.

### 2. Gaussian to Dogs (ODE)
- Maps 2D Gaussian data to a 2D uniform distribution.
- Uses the same architecture and training approach as the first model.
- Investigates how the source distribution affects the mapping accuracy and sample trajectories.

### 3. Gaussian to Dogs (Stochastic)
- Uses a neural network trained with a noise-based target to guide samples towards the target distribution.
- Applies an adapted stochastic sampling method inspired by reverse-time SDEs.
- Explores the differences between deterministic and stochastic approaches, although the implementation does not use a standard reverse-SDE solver.

## Experiments

All three models were trained for 5,000 iterations using the Adam optimizer.

- **Distribution mapping:** Compared how closely each model reproduced the target distribution.
- **Sample trajectories:** Visualised the movement of samples between their initial and final distributions.
- **ODE vs stochastic:** Compared the behaviour of deterministic and stochastic approaches.
- **Source distributions:** Investigated the differences between mapping Gaussian and uniform inputs.

The ODE models produced relatively smooth trajectories, while the stochastic approach introduced randomness but was less reliable at reproducing the target distribution.

## Running the Project

The project contains three Jupyter notebooks, developed using Google Colab:

- `cats_to_dogs_ode.ipynb`
- `gaussian_to_dogs_ode.ipynb`
- `gaussian_to_dogs_sde.ipynb`

To run the experiments:

1. Open a notebook in Google Colab.
2. Run all cells to train the model and generate the visualisations.

The notebooks use PyTorch, NumPy, and Matplotlib. They generate their own sample data, so no external datasets are required.

Each model trains for 5,000 iterations with a batch size of 128, then generates scatter plots showing the initial, intermediate, and final distributions. Training parameters can be adjusted directly in the notebooks.

## Report

See [report.pdf](report.pdf) for the full methodology, experiments, and results.