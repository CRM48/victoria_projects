# Autoencoders for Image Reconstruction and Generation

A project exploring the use of autoencoders to reconstruct and generate images. Two convolutional neural network models were implemented using PyTorch, comparing their reconstruction accuracy, generation quality, and the effects of latent space dimensionality.

## Models

### 1. Variational Autoencoder (VAE)
- Uses a convolutional encoder and decoder to reconstruct grayscale images.
- Learns a probability distribution in the latent space, allowing new images to be generated from random samples.
- Trained using a combination of binary cross-entropy and KL divergence.

### 2. Modified Autoencoder (AE)
- Uses a convolutional encoder and decoder with Gaussian noise added to the latent representation during training.
- Trained using Mean Squared Error (MSE) with additional regularisation.
- Designed to investigate the effects of noise and latent dimensionality on reconstruction accuracy and generation quality.

## Experiments

Both models were trained on randomly generated 28×28 grayscale images containing circles, triangles, and rectangles.

- **Reconstruction:** Compared how accurately each model reproduced the original images.
- **Generation:** Compared images generated from randomly sampled latent vectors.
- **Latent dimensionality:** Tested latent spaces of 2, 8, 16, and 64 dimensions.
- **Information rate:** Examined how much information was retained in the modified autoencoder's latent representation.

The modified AE generally produced more accurate reconstructions, while the VAE was better suited to generating new images from random latent samples.

## Running the Project

The project is contained in `autoencoders.ipynb` and was developed using Kaggle.

1. Open the notebook in Kaggle or Google Colab.
2. Enable GPU acceleration if available.
3. Run all cells to train the models and generate the visualisations.

The notebook uses PyTorch, NumPy, Matplotlib, and Pillow. It generates its own dataset, so no external data files are required.

Each model trains for 20 epochs with a batch size of 64, printing training and validation losses. The notebook then generates comparisons of reconstructed and newly generated images.

Model parameters, including the learning rate, number of epochs, noise level, and latent dimensions, can be adjusted in the notebook.

## Report

See [report.pdf](report.pdf) for the full methodology, experiments, and results.