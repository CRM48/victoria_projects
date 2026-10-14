import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import org.objectweb.asm.Type;
import org.objectweb.asm.AnnotationVisitor;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.FieldVisitor;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;

/**
 * Extract a set of test classes present in any of the input jars or folders.
 * The following defines a test class:
 * - classes, fields or methods use an annotation with a name starting with
 * org.junit .
 * - there are static method invocations of any method declared in any of the
 * following classes: org.junit.Assume,
 * org.junit.Assert, org.junit.jupiter.api.Assumptions or
 * org.junit.jupiter.api.Assertions
 * Classes are represented by their qualified class names, such as
 * "java.lang.String" or "java.util.Map$Entry" (for inner classes).
 */
public class TestClassDetector {

    public static Set<String> extractTestClasses(File... jarsOrFolders) {
        Set<String> testClasses = new HashSet<>();
        Map<String, File> folderClassMap = new HashMap<>();
        Map<String, Map<String, JarEntry>> jarClassMap = new HashMap<>();

        // Extracts class names from folders and jar files
        for (File f : jarsOrFolders) {
            if (f.isDirectory()) {
                extractClassNamesFromFolder("", f, folderClassMap);
            } else if (f.isFile() && f.getName().endsWith(".jar")) {
                extractClassNamesFromJar(f, jarClassMap);
            }
        }

        // Visits each class (in folders) using the custom visitor class
        for (String className : folderClassMap.keySet()) {
            File classFile = folderClassMap.get(className);
            try (InputStream in = new FileInputStream(classFile)) {
                ClassReader reader = new ClassReader(in);
                reader.accept(new TestClassVisitor(testClasses), 0);
            } catch (IOException e) {

            }
        }

        // Visits each class (in jar files) using the custom visitor class
        for (String className : jarClassMap.keySet()) {
            Map<String, JarEntry> sources = jarClassMap.get(className);
            for (String jarPath : sources.keySet()) {
                JarEntry entry = sources.get(jarPath);

                try (JarFile jarFile = new JarFile(jarPath);
                        InputStream in = jarFile.getInputStream(entry)) {

                    ClassReader reader = new ClassReader(in);
                    reader.accept(new TestClassVisitor(testClasses), 0);

                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        // Returns the set of classes that are test classes
        return testClasses;

    }

    private static void extractClassNamesFromFolder(String previous, File folder, Map<String, File> classMap) {
        File[] files = folder.listFiles();
        if (files == null)
            return;

        for (File f : files) {
            if (f.isDirectory()) {
                extractClassNamesFromFolder(previous + f.getName() + ".", f, classMap); // recurse
            } else if (f.isFile() && f.getName().endsWith(".class")) {
                String name = previous + f.getName().replace(".class", "");
                classMap.put(name, f);
            }
        }
    }

    private static void extractClassNamesFromJar(File jarFile, Map<String, Map<String, JarEntry>> classMap) {
        try (JarFile jar = new JarFile(jarFile.getAbsolutePath())) { // try-with-resources auto-closes
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

    private static class TestClassVisitor extends ClassVisitor {

        private String className;
        private Set<String> testClasses;
        private boolean isTestClass = false;

        public TestClassVisitor(Set<String> testClasses) {
            super(Opcodes.ASM9);
            this.testClasses = testClasses;
        }

        @Override
        public void visit(int version, int access, String name, String signature, String superName,
                String[] interfaces) {
            className = name.replace("/", ".");
            super.visit(version, access, name, signature, superName, interfaces);
        }

        // This method visits the annotation of the class (i.e., any @ commands)
        @Override
        public AnnotationVisitor visitAnnotation(String descriptor, boolean visible) {
            String annotationClass = Type.getType(descriptor).getClassName();
            // If the class has a junit annotation, it is a test class
            if (annotationClass.startsWith("org.junit.")) {
                isTestClass = true;
            }
            return super.visitAnnotation(descriptor, visible);
        }

        // This method visits the annotation of each field
        @Override
        public FieldVisitor visitField(int access, String name, String descriptor, String signature, Object value) {
            return new FieldVisitor(Opcodes.ASM9, super.visitField(access, name, descriptor, signature, value)) {
                @Override
                public AnnotationVisitor visitAnnotation(String descriptor, boolean visible) {
                    String annotationClass = Type.getType(descriptor).getClassName();
                    // If a field has a junit annotation, it is a test class
                    if (annotationClass.startsWith("org.junit.")) {
                        isTestClass = true;
                    }
                    return super.visitAnnotation(descriptor, visible);
                }
            };
        }

        // This method visits each method
        @Override
        public MethodVisitor visitMethod(int access, String name, String descriptor, String signature,
                String[] exceptions) {
            MethodVisitor mv = super.visitMethod(access, name, descriptor, signature, exceptions);

            return new MethodVisitor(Opcodes.ASM9, mv) {
                // This visits the annoation of the method
                @Override
                public AnnotationVisitor visitAnnotation(String descriptor, boolean visible) {
                    String annotationClass = Type.getType(descriptor).getClassName();
                    // If a method has a junit annotation, it is a test class
                    if (annotationClass.startsWith("org.junit.")) {
                        isTestClass = true;
                    }
                    return super.visitAnnotation(descriptor, visible);
                }

                // This visits everytime a method is called
                // Private fields initialisers are compiled into clinit and init methods
                // Therefore, they will also invok this method
                @Override
                public void visitMethodInsn(int opcode, String owner, String name, String descriptor,
                        boolean isInterface) {
                    // If the method is static (INVOKESTATIC will be generated)
                    if (opcode == Opcodes.INVOKESTATIC) {
                        String calledClass = owner.replace("/", ".");
                        // And if the called class is Assert, Assume, Assertions, or Assumptions
                        // Then the overall class is a test class
                        if (calledClass.equals("org.junit.Assert") ||
                                calledClass.equals("org.junit.Assume") ||
                                calledClass.equals("org.junit.jupiter.api.Assertions") ||
                                calledClass.equals("org.junit.jupiter.api.Assumptions")) {
                            isTestClass = true;
                        }
                    }
                    super.visitMethodInsn(opcode, owner, name, descriptor, isInterface);
                }
            };
        }

        @Override
        public void visitEnd() {
            if (isTestClass && className != null) {
                testClasses.add(className);
            }
            super.visitEnd();
        }
    }
}
