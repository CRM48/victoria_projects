import org.jgrapht.graph.DirectedMultigraph;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.FieldVisitor;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;
import org.objectweb.asm.Type;
import org.objectweb.asm.Label;

import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.FileInputStream;
import java.io.FileReader;

/**
 * Build a dependency graph between classes (a class here means code stored in a
 * .class file)
 * from input jars or folders.
 * The resulting graph is directed, and uses custom labelled edges. It does not
 * support self-edges (A -> A)
 * but multiple edges between the same start and end node (with different
 * labels).
 * The vertices are fully qualified class names, such as "java.lang.String" or
 * "java.util.Map$Entry" (for inner classes).
 * See ClassDependencyEdge for details on the edge type being used.
 */
public class ClassDependencyGraphBuilder {
    public static DirectedMultigraph<String, ClassDependencyEdge> buildClassDependencyGraph(File... jarsOrFolders) {
        Map<String, File> folderClassMap = new HashMap<>();
        Map<String, Map<String, JarEntry>> jarClassMap = new HashMap<>();
        Map<String, File> classToSourceMap = new HashMap<>();

        // Extract all the class names from the jars and folders into their respective
        // maps
        // Also get a map of the class name to its source folder or jar
        for (File f : jarsOrFolders) {
            if (f.isDirectory()) {
                extractClassNamesFromFolder("", f, folderClassMap, classToSourceMap);
            } else if (f.isFile() && f.getName().endsWith(".jar")) {
                extractClassNamesFromJar(f, jarClassMap, classToSourceMap);
            }
        }

        // Create a directed multigraph
        DirectedMultigraph<String, ClassDependencyEdge> graph = new DirectedMultigraph<>(ClassDependencyEdge.class);
        Set<String> allClassNames = new HashSet<String>();

        // Add a vertex to the graph for every class
        // Also add all classes to a Set for verification when creating edges
        for (String className : folderClassMap.keySet()) {
            graph.addVertex(className);
            allClassNames.add(className);
        }

        for (String className : jarClassMap.keySet()) {
            graph.addVertex(className);
            allClassNames.add(className);
        }

        // Visit each class in folders
        // This is used to determine and set edges between the vertices
        for (String className : folderClassMap.keySet()) {
            File classFile = folderClassMap.get(className);
            try (InputStream in = new FileInputStream(classFile)) {
                ClassReader reader = new ClassReader(in);
                reader.accept(new DependencyClassVisitor(graph, allClassNames, classToSourceMap), 0);
            } catch (IOException e) {

            }
        }

        // Visit each class in Jar files
        for (String className : jarClassMap.keySet()) {
            Map<String, JarEntry> sources = jarClassMap.get(className);
            for (String jarPath : sources.keySet()) {
                JarEntry entry = sources.get(jarPath);

                try (JarFile jarFile = new JarFile(jarPath);
                        InputStream in = jarFile.getInputStream(entry)) {

                    ClassReader reader = new ClassReader(in);
                    reader.accept(new DependencyClassVisitor(graph, allClassNames, classToSourceMap), 0);

                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        // Return the fully constructed graph
        return graph;
    }

    /**
     * Gets the names of all classes in a file
     * 
     * @param previous         Used for recursion
     * @param folder           Name of the current folder
     * @param classMap         A map from classnames to their File
     * @param classToSourceMap A map from classname to its source folder
     */
    private static void extractClassNamesFromFolder(String previous, File folder, Map<String, File> classMap,
            Map<String, File> classToSourceMap) {
        File[] files = folder.listFiles();
        if (files == null)
            return;

        for (File f : files) {
            if (f.isDirectory()) {
                extractClassNamesFromFolder(previous + f.getName() + ".", f, classMap, classToSourceMap);
            } else if (f.isFile() && f.getName().endsWith(".class")) {
                String name = previous + f.getName().replace(".class", "");
                classMap.put(name, f);
                classToSourceMap.put(name, folder);
            }
        }
    }

    /**
     * Gets the names of all classes in a jar file
     * 
     * @param jarFile          Name of the jar File
     * @param classMap         A map from classnames to their File
     * @param classToSourceMap A map from classname to its source jar file
     */
    private static void extractClassNamesFromJar(File jarFile, Map<String, Map<String, JarEntry>> classMap,
            Map<String, File> classToSourceMap) {
        try (JarFile jar = new JarFile(jarFile.getAbsolutePath())) { // try-with-resources auto-closes
            Enumeration<JarEntry> entries = jar.entries();
            while (entries.hasMoreElements()) {
                JarEntry entry = entries.nextElement();
                if (entry.getName().endsWith(".class")) {
                    String name = entry.getName().replace("/", ".").replace(".class", "");
                    Map<String, JarEntry> innerMap = classMap.getOrDefault(name, new HashMap<>());
                    innerMap.put(jarFile.getAbsolutePath(), entry);
                    classMap.put(name, innerMap);
                    classToSourceMap.put(name, jarFile);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static class DependencyClassVisitor extends ClassVisitor {

        private Set<String> allClassNames;
        private DirectedMultigraph<String, ClassDependencyEdge> graph;
        private Map<String, File> classToSourceMap;
        private String className;

        private boolean usesServiceLoader = false;
        private Set<String> interfacesCalledByClass = new HashSet<>();

        /**
         * Used to set all local variables
         * 
         * @param graph            The Directed Multigraph
         * @param allClassNames    All valid classes that were in any input
         * @param classToSourceMap A mapping from class names to their source folder or
         *                         jar
         */
        public DependencyClassVisitor(DirectedMultigraph<String, ClassDependencyEdge> graph,
                Set<String> allClassNames, Map<String, File> classToSourceMap) {
            super(Opcodes.ASM9);
            this.graph = graph;
            this.allClassNames = allClassNames;
            this.classToSourceMap = classToSourceMap;
        }

        @Override
        public void visit(int version, int access, String name, String signature, String superName,
                String[] interfaces) {
            className = name.replace("/", ".");

            // If the class has a superClass (meaning it extracts from a class)
            // And if that class is one of the input classes
            // Add the superclass edge
            if (superName != null) {
                String superClass = superName.replace("/", ".");
                if (allClassNames.contains(superClass) && !className.equals(superClass)) {
                    ClassDependencyEdge edge = new ClassDependencyEdge(ClassDependencyEdge.DependencyType.SUPERCLASS);
                    graph.addEdge(className, superClass, edge);
                }
            }

            // If the class implements an interface
            // And if that interface is an input .class file
            // Add an edge labelled interface
            if (interfaces != null) {
                for (String iface : interfaces) {
                    String normiface = iface.replace("/", ".");
                    if (allClassNames.contains(normiface) && !className.equals(normiface)) {
                        ClassDependencyEdge edge = new ClassDependencyEdge(
                                ClassDependencyEdge.DependencyType.INTERFACE);
                        graph.addEdge(className, normiface, edge);
                    }
                }
            }
        }

        @Override
        public void visitInnerClass(String name, String outerName, String innerName, int access) {
            if (!name.equals(className.replace(".", "/")))
                return;
            String innerClass = name.replace("/", ".");
            String outerClass = outerName != null ? outerName.replace("/", ".") : null;

            // If a class has an outerclass, and that outerclass is a valid input file, add
            // the edge OUTERCLASS
            if (outerClass != null && allClassNames.contains(outerClass) && !className.equals(outerClass)) {
                ClassDependencyEdge edge = new ClassDependencyEdge(ClassDependencyEdge.DependencyType.OUTERCLASS);
                graph.addEdge(innerClass, outerClass, edge);
            }
            super.visitInnerClass(name, outerName, innerName, access);
        }

        @Override
        public MethodVisitor visitMethod(int access, String name, String descriptor,
                String signature, String[] exceptions) {
            MethodVisitor mv = super.visitMethod(access, name, descriptor, signature, exceptions);
            Type returnType = Type.getReturnType(descriptor);
            Type[] argTypes = Type.getArgumentTypes(descriptor);

            // If a method in a class returns an instance of another input class, add this
            // edge
            String returnClass = returnType.getClassName().replace("/", ".");
            if (allClassNames.contains(returnClass) && !className.equals(returnClass)) {
                ClassDependencyEdge edge = new ClassDependencyEdge(
                        ClassDependencyEdge.DependencyType.METHOD_RETURN_TYPE);
                graph.addEdge(className, returnClass, edge);
            }

            // If a method in a class takes another input class as an argument, add this
            // edge
            for (Type arg : argTypes) {
                String paramClass = arg.getClassName().replace("/", ".");
                if (allClassNames.contains(paramClass) && !className.equals(paramClass)) {
                    ClassDependencyEdge edge = new ClassDependencyEdge(
                            ClassDependencyEdge.DependencyType.METHOD_PARAMETER_TYPE);
                    graph.addEdge(className, paramClass, edge);
                }
            }

            // If a method in a class throws an exception of another input class, add this
            // edge
            if (exceptions != null) {
                for (String ex : exceptions) {
                    String exClass = ex.replace("/", ".");
                    if (allClassNames.contains(exClass) && !className.equals(exClass)) {
                        ClassDependencyEdge edge = new ClassDependencyEdge(
                                ClassDependencyEdge.DependencyType.DECLARED_EXCEPTION_TYPE);
                        graph.addEdge(className, exClass, edge);
                    }
                }
            }

            return new MethodVisitor(Opcodes.ASM9, mv) {

                @Override
                public void visitTypeInsn(int opcode, String type) {
                    if (opcode == Opcodes.NEW || opcode == Opcodes.ANEWARRAY || opcode == Opcodes.MULTIANEWARRAY) {
                        String insnClass = type.replace("/", ".");
                        // If a class is instantiated or a new array of a class is created,
                        // and that class is one of the input classes, add an instantiation edge
                        if (allClassNames.contains(insnClass) && !className.equals(insnClass)) {
                            ClassDependencyEdge edge = new ClassDependencyEdge(
                                    ClassDependencyEdge.DependencyType.INSTANTIATION);
                            graph.addEdge(className, insnClass, edge);
                        }
                    }
                    super.visitTypeInsn(opcode, type);
                }

                @Override
                public void visitLocalVariable(String name, String descriptor, String signature,
                        Label start, Label end, int index) {
                    Type varType = Type.getType(descriptor);
                    String typeName = varType.getClassName().replace("/", ".");
                    // If a local variable in the method has a type that is one of the input
                    // classes,
                    // add a local variable type edge
                    if (allClassNames.contains(typeName) && !className.equals(typeName)) {
                        ClassDependencyEdge edge = new ClassDependencyEdge(
                                ClassDependencyEdge.DependencyType.LOCAL_VARIABLE_TYPE);
                        graph.addEdge(className, typeName, edge);
                    }
                    super.visitLocalVariable(name, descriptor, signature, start, end, index);
                }

                @Override
                public void visitMethodInsn(int opcode, String owner, String name, String descriptor,
                        boolean isInterface) {

                    super.visitMethodInsn(opcode, owner, name, descriptor, isInterface);
                    String calledClass = owner.replace("/", ".");

                    if (owner.equals("java/util/ServiceLoader") && name.equals("load")) {
                        usesServiceLoader = true;
                    }

                    if (allClassNames.contains(calledClass) && isInterface) {
                        interfacesCalledByClass.add(calledClass);
                    }
                }
            };
        }

        @Override
        public FieldVisitor visitField(int access, String name, String descriptor, String signature, Object value) {
            Type fieldType = Type.getType(descriptor);
            String typeName = fieldType.getClassName().replace("/", ".");

            if (allClassNames.contains(typeName) && !className.equals(typeName)) {
                ClassDependencyEdge edge = new ClassDependencyEdge(ClassDependencyEdge.DependencyType.FIELD_TYPE);
                graph.addEdge(className, typeName, edge);
            }

            return super.visitField(access, name, descriptor, signature, value);
        }

        @Override
        public void visitEnd() {
            if (usesServiceLoader) {
                for (String iface : interfacesCalledByClass) {
                    Set<String> providers = getProviders(iface);
                    for (String provider : providers) {
                        // If the class uses a ServiceLoader to load implementations of interfaces,
                        // for each interface used, add an edge to all provider classes that arepart of
                        // the input classes
                        if (allClassNames.contains(provider) && !className.equals(provider)) {
                            ClassDependencyEdge edge = new ClassDependencyEdge(
                                    ClassDependencyEdge.DependencyType.OTHER);
                            graph.addEdge(className, provider, edge);
                        }
                    }
                }
            }
            super.visitEnd();
        }

        // Returns a set of provider class names for the given interface
        private Set<String> getProviders(String ifaceName) {
            Set<String> providers = new HashSet<>();
            File source = classToSourceMap.get(className);
            boolean isJar = source.getName().endsWith(".jar");
            if (isJar) {
                try (JarFile jar = new JarFile(source)) {
                    // look for the interface file in the META-INF/services folder
                    String entryName = "META-INF/services/" + ifaceName;
                    JarEntry entry = jar.getJarEntry(entryName);
                    // If it exists, add all listed provider class names
                    if (entry != null) {
                        try (InputStream in = jar.getInputStream(entry);
                                BufferedReader br = new BufferedReader(new InputStreamReader(in))) {
                            String line;
                            while ((line = br.readLine()) != null) {
                                line = line.strip();
                                // ignore empty lines and commented (#) lines
                                if (!line.isEmpty() && !line.startsWith("#")) {
                                    providers.add(line);
                                }
                            }
                        }
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            } else {
                int packageDepth = className.substring(0, className.lastIndexOf('.')).split("\\.").length;
                File parentFolder = classToSourceMap.get(className);
                for (int i = 0; i < packageDepth; i++) {
                    parentFolder = parentFolder.getParentFile();
                }
                File serviceFile = new File(parentFolder, "META-INF/services/" + ifaceName);
                if (serviceFile.exists()) {
                    try (BufferedReader br = new BufferedReader(new FileReader(serviceFile))) {
                        String line;
                        while ((line = br.readLine()) != null) {
                            line = line.strip();
                            if (!line.isEmpty() && !line.startsWith("#")) {
                                providers.add(line);
                            }
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }

            return providers;

        }
    }
}
