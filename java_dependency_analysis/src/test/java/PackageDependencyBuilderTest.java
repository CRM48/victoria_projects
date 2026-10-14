import org.jgrapht.graph.DefaultDirectedGraph;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.DirectedMultigraph;
import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.io.File;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Simple test case to use as template for more sophisticated tests.
 * Some tests will initially fail.
 * 
 * @author jens dietrich
 */
public class PackageDependencyBuilderTest {
        private File projectFolder = null;

        @BeforeEach
        public void setup() throws Exception {
                projectFolder = new File(PackageDependencyBuilderTest.class.getResource("/testproject1").toURI());
                Assumptions.assumeTrue(projectFolder.exists());
        }

        @Test
        public void testBuildFromFolder() {
                File compiledClassesFolder = new File(projectFolder, "target/classes");
                Assumptions.assumeTrue(compiledClassesFolder.exists(),
                                "Compiled classes folder " + compiledClassesFolder.getAbsolutePath()
                                                + " not found, build test project in src/test/resources/ first by running \"mvn compile\"");
                DirectedMultigraph<String, ClassDependencyEdge> classGraph = ClassDependencyGraphBuilder
                                .buildClassDependencyGraph(compiledClassesFolder);
                DefaultDirectedGraph<String, DefaultEdge> pckGraph = PackageDependencyGraphBuilder
                                .buildPackageDependencyGraph(classGraph);
                testGraph(pckGraph);
        }

        @Test
        public void testBuildFromJar() {
                File jar = new File(projectFolder, "target/testproject1-1.0.0.jar");
                Assumptions.assumeTrue(jar.exists(), "Jar " + jar.getAbsolutePath()
                                + " not found, build test project in src/test/resources/ first by running \"mvn package\"");
                DirectedMultigraph<String, ClassDependencyEdge> classGraph = ClassDependencyGraphBuilder
                                .buildClassDependencyGraph(jar);
                DefaultDirectedGraph<String, DefaultEdge> pckGraph = PackageDependencyGraphBuilder
                                .buildPackageDependencyGraph(classGraph);
                testGraph(pckGraph);
        }

        private void testGraph(DefaultDirectedGraph<String, DefaultEdge> graph) {

                assertTrue(graph != null, "graph must be null (have you implemented the graph builder?)");
                assertEquals(2, graph.vertexSet().size());
                assertTrue(graph.vertexSet().contains("pck1"));
                assertTrue(graph.vertexSet().contains("pck2"));

                assertEquals(1, graph.edgeSet().size());

                DefaultEdge e = graph.getEdge("pck1", "pck2");
                assertTrue(e != null);
        }
}
