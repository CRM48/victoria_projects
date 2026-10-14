import org.jgrapht.graph.DefaultDirectedGraph;
import org.jgrapht.graph.DirectedMultigraph;
import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.io.File;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Simple test case to useas template for more sophisticated tests.
 * All tests will initially fail.
 * 
 * @author jens dietrich
 */
public class ClassDependencyBuilderTest {
    private File projectFolder = null;

    @BeforeEach
    public void setup() throws Exception {
        projectFolder = new File(ClassDependencyBuilderTest.class.getResource("/testproject1").toURI());
        Assumptions.assumeTrue(projectFolder.exists());
    }

    @Test
    public void testBuildFromFolder() {
        File compiledClassesFolder = new File(projectFolder, "target/classes");
        Assumptions.assumeTrue(compiledClassesFolder.exists(),
                "Compiled classes folder " + compiledClassesFolder.getAbsolutePath()
                        + " not found, build test project in src/test/resources/ first by running \"mvn compile\"");
        System.out.println(compiledClassesFolder.getAbsolutePath());
        DirectedMultigraph<String, ClassDependencyEdge> graph = ClassDependencyGraphBuilder
                .buildClassDependencyGraph(compiledClassesFolder);
        testGraph(graph);
    }

    @Test
    public void testBuildFromJar() {
        File jar = new File(projectFolder, "target/testproject1-1.0.0.jar");
        Assumptions.assumeTrue(jar.exists(), "Jar " + jar.getAbsolutePath()
                + " not found, build test project in src/test/resources/ first by running \"mvn package\"");
        DirectedMultigraph<String, ClassDependencyEdge> graph = ClassDependencyGraphBuilder
                .buildClassDependencyGraph(jar);
        testGraph(graph);
    }

    private void testGraph(DirectedMultigraph<String, ClassDependencyEdge> graph) {
        assertTrue(graph != null, "graph must be null (have you implemented the graph builder?)");

        assertEquals(3, graph.vertexSet().size(), "vertex count failed");
        assertTrue(graph.vertexSet().contains("pck1.A"), "A failed");
        assertTrue(graph.vertexSet().contains("pck1.B"), "B failed");
        assertTrue(graph.vertexSet().contains("pck2.C"), "C failed");

        assertEquals(2, graph.edgeSet().size(), "edge count failed");

        ClassDependencyEdge e1 = graph.getEdge("pck1.B", "pck1.A");
        assertTrue(e1 != null);
        assertTrue(e1.getType() == ClassDependencyEdge.DependencyType.SUPERCLASS);

        ClassDependencyEdge e2 = graph.getEdge("pck1.A", "pck2.C");
        assertTrue(e2 != null);
        assertTrue(e2.getType() == ClassDependencyEdge.DependencyType.FIELD_TYPE);
    }
}
