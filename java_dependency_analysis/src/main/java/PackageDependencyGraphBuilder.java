import org.jgrapht.Graph;
import org.jgrapht.graph.DefaultDirectedGraph;
import org.jgrapht.graph.DefaultEdge;

/**
 * Build a dependency graph between packages from a class dependency graph.
 * Package nodes are represented as vertices (nodes) using their name, e.g.
 * "java.util".
 * Package A depends on package B if and only if some class in A depends on come
 * class in B.
 */
public class PackageDependencyGraphBuilder {
    public static DefaultDirectedGraph<String, DefaultEdge> buildPackageDependencyGraph(
            Graph<String, ClassDependencyEdge> classDependencyGraph) {
        DefaultDirectedGraph<String, DefaultEdge> graph = new DefaultDirectedGraph<>(DefaultEdge.class);

        // Add all the packages as vertices
        for (String vertex : classDependencyGraph.vertexSet()) {
            graph.addVertex(getPackage(vertex));
        }
        // loop through all the edges
        // If an edge is between classes of two different packages add an edge between
        // these packages
        // Only add edges between packages once
        for (ClassDependencyEdge edge : classDependencyGraph.edgeSet()) {
            String source = classDependencyGraph.getEdgeSource(edge);
            String target = classDependencyGraph.getEdgeTarget(edge);
            String sourcePck = getPackage(source);
            String targetPck = getPackage(target);
            if (!graph.containsEdge(sourcePck, targetPck) && !sourcePck.equals(targetPck)) {
                graph.addEdge(sourcePck, targetPck);
            }

        }
        return graph;
    }

    // Get the name of the package
    // Just a substring of all characters before the last dot
    private static String getPackage(String className) {
        int lastDot = className.lastIndexOf('.');
        if (lastDot == -1) {
            return "";
        }
        return className.substring(0, lastDot);
    }
}
