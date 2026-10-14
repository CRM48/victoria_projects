import com.sun.tools.attach.VirtualMachine;

public class AgentAttacher {
    public static void attachAgent(String agentPath) {
        try {
            String pid = Long.toString(ProcessHandle.current().pid());
            VirtualMachine vm = VirtualMachine.attach(pid);
            vm.loadAgent(agentPath);
            vm.detach();
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to attach agent", e);
        }
    }
}
