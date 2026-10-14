import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.jgrapht.graph.DefaultDirectedGraph;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.DirectedMultigraph;

/**
 * Create a mermaid file (*.mermaid) representing the package dependency graph.
 * The script will require two arguments:
 * 1. a jar file or folder containing java byte code -- this is the program to
 * be analysed, this file or folder must exist
 * 2. a name of a file where the mermaid generated will be stored
 */
public class PackageDependencyGraphVisualiser {
    public static void main(String[] args) throws IOException, InterruptedException {
        // Check valid arguments
        if (args.length != 2) {
            throw new IllegalArgumentException("two arguments required");
        }
        File input = new File(args[0]);
        if (!input.exists()) {
            throw new IllegalArgumentException("input does not exist: " + input.getAbsolutePath());
        }

        // Create a class dependency graph using the first argumnt (a folder or jar file
        // location)
        DirectedMultigraph<String, ClassDependencyEdge> classGraph = ClassDependencyGraphBuilder
                .buildClassDependencyGraph(input);
        // Create a package dependency graph using the class dependency graph
        DefaultDirectedGraph<String, DefaultEdge> pckGraph = PackageDependencyGraphBuilder
                .buildPackageDependencyGraph(classGraph);

        // Get the abstractness of all classes in the input
        Map<String, Double> abstractness = AbstractnessCalculator.calculateClassAbstractness(input);

        // Get all the strongly connected components
        Set<Set<String>> sccs = PackageDependencyCycleDetector.detectCycles(pckGraph);

        // Create and initialise a map for packages to their abstractness
        // The mapping is to a double 2D array which will have the sum of the values,
        // and the number of classes in the package
        Map<String, Double[]> stats = new HashMap<>();
        for (String pkg : pckGraph.vertexSet()) {
            stats.put(pkg, new Double[] { 0.0, 0.0 });
        }

        // populate the stats map
        for (Map.Entry<String, Double> entry : abstractness.entrySet()) {
            String className = entry.getKey();
            Double value = entry.getValue();

            for (String pkg : pckGraph.vertexSet()) {
                if (className.startsWith(pkg + ".")) {
                    stats.get(pkg)[0] += value;
                    stats.get(pkg)[1] += 1;
                    break;
                }
            }
        }

        // Use the mapping above to calculate the abstractness for each package
        Map<String, Double> packageAverage = new HashMap<>();
        for (String pkg : pckGraph.vertexSet()) {
            Double[] data = stats.get(pkg);
            if (data[1] > 0) {
                packageAverage.put(pkg, data[0] / data[1]);
            }
        }

        // Convert the data to mermaid code
        String mermaidCode = toMermaid(pckGraph, packageAverage, sccs);
        String output = args[1];

        // Write this mermaid code to the output file
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(output))) {
            writer.write(mermaidCode);
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    // Converts the data to mermaid code
    public static String toMermaid(DefaultDirectedGraph<String, DefaultEdge> graph,
            Map<String, Double> packageAverage, Set<Set<String>> cycles) {
        // A string builder is used to construct the code
        StringBuilder sb = new StringBuilder();

        // Top down graph
        sb.append("graph TD\n");

        // Get a set of all nodes and edges that are part of cycles
        Set<String> cycleNodes = new HashSet<>();
        Set<String> cycleEdges = new HashSet<>();
        for (Set<String> cycle : cycles) {
            cycleNodes.addAll(cycle);
            for (DefaultEdge edge : graph.edgeSet()) {
                String source = graph.getEdgeSource(edge);
                String target = graph.getEdgeTarget(edge);
                if (cycle.contains(source) && cycle.contains(target)) {
                    cycleEdges.add(source + "->" + target);
                }
            }
        }

        // Add the vertices to the code
        for (String vertex : graph.vertexSet()) {
            Double avg = packageAverage.get(vertex);
            String label = avg != null ? String.format("%s: %.2f", vertex, avg) : vertex;
            sb.append("    ").append(vertex).append("[").append(label).append("]\n");
        }

        // Add the edges to the code
        int count = 0;
        List<Integer> colouredEdges = new ArrayList<>();
        for (DefaultEdge edge : graph.edgeSet()) {
            String source = graph.getEdgeSource(edge);
            String target = graph.getEdgeTarget(edge);
            String edgeKey = source + "->" + target;

            // Keep track of in what order the cycle edges are added
            if (cycleEdges.contains(edgeKey)) {
                colouredEdges.add(count);
            }
            sb.append("    ").append(source).append(" --> ").append(target).append("\n");
            count++;
        }

        // Assign cycle node class to cycle nodes
        if (!cycleNodes.isEmpty()) {
            sb.append("    class ").append(String.join(",", cycleNodes)).append(" cycleNode;\n");
        }
        // Assign default node class to all nodes
        if (!graph.vertexSet().isEmpty()) {
            sb.append("    class ").append(String.join(",", graph.vertexSet())).append(" defaultNode;\n");
        }

        // Create a string that seperates the indices of all coloured edges using a
        // comma
        String colouredEdgesString = colouredEdges.stream().map(String::valueOf).collect(Collectors.joining(","));

        // Create the classes and the linkStyle for the edges
        sb.append("    classDef defaultNode fill:#555555,stroke-width:2px,color:#ffffff;\n");
        sb.append("    classDef cycleNode stroke:#ff0000,stroke-width:2px;\n");
        if (!colouredEdgesString.equals("")) {
            sb.append("    linkStyle " + colouredEdgesString + " stroke:#ff0000,stroke-width:2px;\n");
        }

        // Return the string
        return sb.toString();
    }
}
