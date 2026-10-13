import matplotlib.pyplot as plt
from sklearn.datasets import fetch_openml
from sklearn.manifold import TSNE
from sklearn.utils import shuffle
from sklearn.preprocessing import StandardScaler
import numpy as np

# Load MNIST
mnist = fetch_openml("mnist_784", version=1, as_frame=False)
X = mnist.data
y = mnist.target.astype(int)



# Scale data and take a subset (t-SNE is slow)
subset_size = 2000
X_shuffled, y_shuffled = shuffle(X, y, random_state=48)
X_subset = X_shuffled[:subset_size]
y_subset = y_shuffled[:subset_size]
X_subset = StandardScaler().fit_transform(X_subset)

# Apply t-SNE
perplexity = 100
tsne = TSNE(n_components=2, perplexity=perplexity, random_state=48)

X_tsne = tsne.fit_transform(X_subset)

# Plot with legend instead of colorbar
plt.figure(figsize=(10, 8))
colors = plt.cm.tab10.colors
for digit in range(10):
    idx = y_subset == digit
    plt.scatter(X_tsne[idx, 0], X_tsne[idx, 1], 
                label=str(digit), c=[colors[digit]], s=10, alpha=0.7)

plt.legend(title="Digit Label", markerscale=2)
plt.title(f"t-SNE of MNIST (Perplexity: {perplexity})")
plt.xlabel('t-SNE-1')
plt.ylabel('t-SNE-2')
plt.grid(True)
plt.tight_layout()
plt.show()
