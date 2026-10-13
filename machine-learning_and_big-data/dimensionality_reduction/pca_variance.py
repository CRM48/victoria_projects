import numpy as np
import matplotlib.pyplot as plt

from sklearn.datasets import fetch_openml
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

# Load MNIST
mnist = fetch_openml("mnist_784", version=1, as_frame=False)
X = mnist.data

# Standardise features
X_scaled = StandardScaler().fit_transform(X)

# Calculate explained variance
pca = PCA(n_components=100, random_state=48)
pca.fit(X_scaled)

cumulative_variance = np.cumsum(pca.explained_variance_ratio_)

# Plot
plt.figure(figsize=(10, 8))
plt.plot(range(1, len(cumulative_variance) + 1), cumulative_variance, linewidth=2)
plt.xlabel('Number of Principal Components')
plt.ylabel('Cumulative Explained Variance')
plt.title('PCA of MNIST - Cumulative Explained Variance')
plt.ylim(0, 1)
plt.grid(True)
plt.show()