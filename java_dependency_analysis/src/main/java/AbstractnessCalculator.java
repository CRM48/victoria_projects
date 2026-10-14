import java.io.File;
import java.io.FileInputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Enumeration;

import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;

import java.io.IOException;
import java.io.InputStream;

/**
 * Create a map that maps each class present in any of the input jars or folders
 * to a number
 * calculated as the ratio of abstract to all methods.
 * Note that abstractness is defined by the abstract flag in byte code, not the
 * use of the abstract key word in source code.
 * For instance, an interface usually contains abstract methods (without method
 * body) not explicitly declared as abstract in source code.
 * In bytecode however, these methods would still be flagged as ACC_ABSTRACT.
 * Classes are represented by their qualified class names, such as
 * "java.lang.String" or "java.util.Map$Entry" (for inner classes).
 */
public class AbstractnessCalculator {
    public static Map<String, Double> calculateClassAbstractness(File... jarsOrFolders) {
        Map<String, Double> abstractnessMap = new HashMap<>();
        Map<String, File> folderClassMap = new HashMap<>();
        Map<String, Map<String, JarEntry>> jarClassMap = new HashMap<>();

        // Get the class names from each folder and jar file
        for (File f : jarsOrFolders) {
            if (f.isDirectory()) {
                extractClassNamesFromFolder("", f, folderClassMap);
            } else if (f.isFile() && f.getName().endsWith(".jar")) {
                extractClassNamesFromJar(f, jarClassMap);
            }
        }

        // Visit the contents of each .class file (in folders) using the visitor class
        for (String className : folderClassMap.keySet()) {
            File classFile = folderClassMap.get(className);
            try (InputStream in = new FileInputStream(classFile)) {
                ClassReader reader = new ClassReader(in);
                reader.accept(new AbstractnessClassVisitor(abstractnessMap), 0);
            } catch (IOException e) {

            }
        }

        // Visit the contents of each .class file (in jar files) using the visitor class
        for (String className : jarClassMap.keySet()) {
            Map<String, JarEntry> sources = jarClassMap.get(className);
            for (String jarPath : sources.keySet()) {
                JarEntry entry = sources.get(jarPath);

                try (JarFile jarFile = new JarFile(jarPath);
                        InputStream in = jarFile.getInputStream(entry)) {

                    ClassReader reader = new ClassReader(in);
                    reader.accept(new AbstractnessClassVisitor(abstractnessMap), 0);

                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        // Return a mapping of the class name to its abstractness
        return abstractnessMap;
    }

    // Used to get the class names of .class files in a folder
    private static void extractClassNamesFromFolder(String previous, File folder, Map<String, File> classMap) {
        File[] files = folder.listFiles();
        if (files == null)
            return;

        for (File f : files) {
            if (f.isDirectory()) {
                extractClassNamesFromFolder(previous + f.getName() + ".", f, classMap);
            } else if (f.isFile() && f.getName().endsWith(".class")) {
                String name = previous + f.getName().replace(".class", "");
                classMap.put(name, f);
            }
        }
    }

    // Used to get the class names of .class files in a jar file
    private static void extractClassNamesFromJar(File jarFile, Map<String, Map<String, JarEntry>> classMap) {
        try (JarFile jar = new JarFile(jarFile.getAbsolutePath())) {
            Enumeration<JarEntry> entries = jar.entries();
            while (entries.hasMoreElements()) {
                JarEntry entry = entries.nextElement();
                if (entry.getName().endsWith(".class")) {
                    String name = entry.getName().replace("/", ".").replace(".class", "");
                    Map<String, JarEntry> innerMap = classMap.getOrDefault(name, new HashMap<>());
                    innerMap.put(jarFile.getAbsolutePath(), entry);
                    classMap.put(name, innerMap);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static class AbstractnessClassVisitor extends ClassVisitor {

        private Map<String, Double> abstractness;
        private String className;
        private double abstractCount = 0;
        private double methodCount = 0;
        private boolean isInterface;
        private boolean isThrowable = false;

        public AbstractnessClassVisitor(Map<String, Double> abstractness) {
            super(Opcodes.ASM9);
            this.abstractness = abstractness;
        }

        @Override
        public void visit(int version, int access, String name, String signature, String superName,
                String[] interfaces) {
            className = name.replace("/", ".");
            // Set isInterface
            isInterface = (access & Opcodes.ACC_INTERFACE) != 0;
            // Set isThrowable
            isThrowable = isSubclassOf(superName, "java/lang/Throwable");
        }

        // Checks if a class is a subclass of another class
        // Used to check for direct or indirect extension of Throwable
        private boolean isSubclassOf(String currentName, String targetName) {
            if (currentName == null)
                return false;
            if (currentName.equals(targetName))
                return true;

            try {
                Class<?> current = Class.forName(currentName.replace('/', '.'));
                Class<?> target = Class.forName(targetName.replace('/', '.'));

                // If the class is found, it should simply b assignable from the target class
                if (target.isAssignableFrom(current)) {
                    return true;
                }
            } catch (ClassNotFoundException e) {
                try {
                    // If the class isn't found, recurse through the superclass and the interfaces
                    // Check if any of them extend (directly or indirectly) the target class
                    ClassReader reader = new ClassReader(currentName);
                    String superName = reader.getSuperName();
                    String[] interfaces = reader.getInterfaces();

                    if (superName != null && isSubclassOf(superName, targetName))
                        return true;

                    for (String iface : interfaces) {
                        if (isSubclassOf(iface, targetName))
                            return true;
                    }
                } catch (IOException ex) {
                    return false;
                }
            }

            return false;
        }

        // Visit each method in the class
        @Override
        public MethodVisitor visitMethod(int access, String name, String descriptor,
                String signature, String[] exceptions) {
            // Ignore init and clinit methods
            if (name.equals("<init>") || name.equals("<clinit>")) {
                return null;
            }
            // (valid) Method visited, so increase method count
            methodCount++;
            boolean isAbstract = (access & Opcodes.ACC_ABSTRACT) != 0;
            // If abstract, add to that count too
            if (isAbstract) {
                abstractCount++;
            }
            return null;
        }

        @Override
        public void visitEnd() {
            double value;
            // If extends throwable, abstractness = 1
            if (isThrowable) {
                value = 1;
            } else if (methodCount == 0) {
                // if no methods, and an interface, abstratness = 1
                if (isInterface) {
                    value = 1;
                } else { // if no methods and class, abstractness = 0
                    value = 0;
                }
            } else { // If class with methods, abstractness = abstract methods / total methods
                value = abstractCount / methodCount;
            }
            abstractness.put(className, value);
            super.visitEnd();
        }
    }
}
