from sklearn.datasets import fetch_openml
from sklearn.manifold import Isomap
from sklearn.utils import shuffle
import matplotlib.pyplot as plt

# Load the MNIST data
mnist = fetch_openml('mnist_784', version=1, as_frame=False)
X, y = mnist.data, mnist.target.astype(int)

X_shuffled, y_shuffled = shuffle(X, y, random_state=48)

# Subsample for memory/performance
subset_size = 2000
X_subset = X_shuffled[:subset_size]
y_subset = y_shuffled[:subset_size]

# Apply Isomap
isomap = Isomap(n_neighbors=5, n_components=2)
X_isomap = isomap.fit_transform(X_subset)

# Visualize the result
plt.figure(figsize=(10, 8))
colors = plt.cm.tab10.colors
for digit in range(10):
    idx = y_subset == digit
    plt.scatter(X_isomap[idx, 0], X_isomap[idx, 1],
                label=str(digit), c=[colors[digit]], s=10, alpha=0.7)

plt.legend(title="Digit Label", markerscale=2)
plt.title("Isomap Embedding of MNIST (2000 Random Samples)")
plt.xlabel("Isomap Component 1")
plt.ylabel("Isomap Component 2")
plt.grid(True)
plt.tight_layout()
plt.show()
