import org.jgrapht.alg.connectivity.KosarajuStrongConnectivityInspector;
import org.jgrapht.graph.DefaultDirectedGraph;
import org.jgrapht.graph.DefaultEdge;

import java.util.Set;
import java.util.stream.Collectors;
import java.util.List;

/**
 * Detect cycles (aka strongly connected components) in the package dependency
 * graph.
 * The set computed contains sets of packages (represented by name), each set
 * represented the vertices in a strongly connected component within the graph.
 */
public class PackageDependencyCycleDetector {
    public static Set<Set<String>> detectCycles(DefaultDirectedGraph<String, DefaultEdge> packageDependencies) {
        // Create a new KoserajuStrongConnectivityInspector from the JGraphT library
        // Use the package dependencies graph as the input parameter
        KosarajuStrongConnectivityInspector<String, DefaultEdge> inspector = new KosarajuStrongConnectivityInspector<>(
                packageDependencies);

        // You can then use this to get a List of all sets of strongly connected
        // components
        List<Set<String>> allSCCs = inspector.stronglyConnectedSets();
        // Return a Set of Sets containing all the SCCs (containing more than one node)
        return allSCCs.stream().filter(scc -> scc.size() > 1).collect(Collectors.toSet());
    }
}
