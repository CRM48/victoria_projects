import java.util.Set;

import nz.ac.vuw.jenz.chipschallenge.Colour;

/**
 * Small helper used by injected probe code to record the chip state.
 * The probe should call recordState(x,y,keysHash) from the instrumented code.
 * Fuzzer.run can call getLastState() immediately after invoking a move to
 * obtain the recorded position for the current thread.
 */
public final class FuzzerHelper {
    private FuzzerHelper() {
    }

    public static final class State {
        public final int x;
        public final int y;
        public final Set<Colour> keys;

        public State(int x, int y, Set<Colour> keys) {
            this.x = x;
            this.y = y;
            this.keys = keys == null ? Set.of() : Set.copyOf(keys);
        }

        public String toString() {
            return "(" + x + ", " + y + ", " + keys + ")";
        }
    }

    private static final ThreadLocal<State> LAST = new ThreadLocal<>();

    public static void recordState(int x, int y, Set<Colour> keys) {
        LAST.set(new State(x, y, keys));
    }

    public static State getLastState() {
        return LAST.get();
    }

    public static void clearLastState() {
        LAST.remove();
    }

    public static int[] getLocation() {
        int x = getLastState().x;
        int y = getLastState().y;
        int[] loc = { x, y };
        return loc;
    }

    public static Set<Colour> getKeys() {
        return getLastState().keys;
    }
}
