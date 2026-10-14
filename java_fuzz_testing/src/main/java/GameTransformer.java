import org.objectweb.asm.*;

import java.lang.instrument.ClassFileTransformer;
import java.security.ProtectionDomain;

public class GameTransformer implements ClassFileTransformer {

    private static final String TARGET_CLASS = "nz/ac/vuw/jenz/chipschallenge/Chip"; // Name of target class
    private static final String TARGET_METHOD = "tryMoveTo"; // Name of the target method
    private static final String TARGET_DESC = "(II)Z"; // Params / returns types in case multiple instances

    @Override
    public byte[] transform(ClassLoader loader, String className, Class<?> classBeingRedefined,
            ProtectionDomain protectionDomain, byte[] classfileBuffer) {

        // If not Chip class, return
        if (className == null || !className.equals(TARGET_CLASS)) {
            return null;
        }

        // Visit and retrieve data from Chip class
        try {
            ClassReader reader = new ClassReader(classfileBuffer);
            ClassWriter writer = new ClassWriter(reader, ClassWriter.COMPUTE_FRAMES);

            reader.accept(new GameStateClassVisitor(writer), ClassReader.EXPAND_FRAMES);

            return writer.toByteArray();

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private static class GameStateClassVisitor extends ClassVisitor {

        public GameStateClassVisitor(ClassVisitor cv) {
            super(Opcodes.ASM9, cv);
        }

        @Override
        public MethodVisitor visitMethod(int access, String name, String descriptor,
                String signature, String[] exceptions) {

            MethodVisitor mv = super.visitMethod(access, name, descriptor, signature, exceptions);

            // Only visit tryMoveTo method
            if (name.equals(TARGET_METHOD) && descriptor.equals(TARGET_DESC)) {
                return new TryMoveToVisitor(Opcodes.ASM9, mv);
            }

            return mv;
        }
    }

    private static class TryMoveToVisitor extends MethodVisitor {

        public TryMoveToVisitor(int api, MethodVisitor mv) {
            super(api, mv);
        }

        @Override
        public void visitInsn(int opcode) {
            // Everytime the method is about to return (i.e., final states are correct)
            if (opcode == Opcodes.IRETURN) {
                // Push current position to the stack and duplicate it
                super.visitVarInsn(Opcodes.ALOAD, 0);
                super.visitFieldInsn(Opcodes.GETFIELD, TARGET_CLASS, "currentPosition",
                        "Lnz/ac/vuw/jenz/chipschallenge/Cell;");
                super.visitInsn(Opcodes.DUP);

                // Get x from current position and swap two top stack elements
                super.visitFieldInsn(Opcodes.GETFIELD, "nz/ac/vuw/jenz/chipschallenge/Cell", "x", "I");
                super.visitInsn(Opcodes.SWAP);

                // Get y from other current position (at top of the stack due to swap)
                super.visitFieldInsn(Opcodes.GETFIELD, "nz/ac/vuw/jenz/chipschallenge/Cell", "y", "I");

                // Get keys value
                super.visitVarInsn(Opcodes.ALOAD, 0);
                super.visitFieldInsn(Opcodes.GETFIELD, TARGET_CLASS, "keys", "Ljava/util/Set;");

                // call recordState with the x, y, and keys value
                super.visitMethodInsn(Opcodes.INVOKESTATIC, "FuzzerHelper", "recordState", "(IILjava/util/Set;)V",
                        false);
            }

            super.visitInsn(opcode);
        }
    }
}