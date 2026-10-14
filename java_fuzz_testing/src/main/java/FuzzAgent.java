import java.lang.instrument.Instrumentation;

public class FuzzAgent {
    public static void premain(String agentArgs, Instrumentation inst) {
        inst.addTransformer(new GameTransformer());
    }

    public static void agentmain(String agentArgs, Instrumentation inst) {
        inst.addTransformer(new GameTransformer());
    }
}