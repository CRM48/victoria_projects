import nz.ac.vuw.jenz.chipschallenge.Game;
import nz.ac.vuw.jenz.chipschallenge.Chip;
import nz.ac.vuw.jenz.chipschallenge.Colour;

import java.util.Set;
import java.util.Map;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashSet;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Queue;

/**
 * Given a game, run a fuzzing campaign, and record unique crashes found in the
 * resultFile
 * using comma-separated format
 * Notes:
 * - the column separator should be ','
 * - the line separator should be System.lineSeparator()
 * - unique crashes means that there are no identical lines
 * - results must be written on-the-fly, not just at the end of the analysis --
 * you can expect that this will be checked with a timeout setting, and the
 * process will be interuppted once the timeout is reached
 * - the format of each line is: "x,y,exception-class" , for instance:
 * "5,8,java.lang.NullPointerException"
 */
public class Fuzzer {
    private static final char[] MOVES = { 'U', 'D', 'L', 'R' };

    public static void run(Game game, File resultFile) {
        Set<String> recordedCrashes = new HashSet<>();
        Set<String> outOfBoundsCoords = new HashSet<>();
        Set<String> visitedCoords = new HashSet<>();
        Map<Colour, String> keyLocations = new HashMap<>();
        Queue<String> sequences = new LinkedList<>();

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(resultFile))) {
            // Check initial moves
            for (char move : MOVES) {
                Chip chip = new Chip(game);
                try {
                    if (applyMove(chip, move)) {
                        sequences.add("" + move);
                    }
                } catch (Exception e) {
                    FuzzerHelper.State crashState = FuzzerHelper.getLastState();
                    if (crashState != null) {
                        String line = crashState.x + "," + crashState.y + "," + e.getClass().getName();
                        if (recordedCrashes.add(line)) {
                            writer.write(line + System.lineSeparator());
                            writer.flush();
                        }
                    }
                }
            }

            while (!sequences.isEmpty()) {
                String seq = sequences.poll();

                for (char moveChar : MOVES) {
                    String newSeq = seq + moveChar;

                    Chip chip = new Chip(game);
                    Chip tempChip = new Chip(game);
                    boolean tempValid = true;
                    try {
                        for (char baseMove : seq.toCharArray()) {
                            if (!applyMove(tempChip, baseMove)) {
                                tempValid = false;
                                break;
                            }
                        }
                    } catch (Exception e) {
                        tempValid = false;
                    }

                    if (!tempValid)
                        continue;

                    int[] baseCoords = FuzzerHelper.getLocation();
                    int[] nextCoords = nextPos(baseCoords, moveChar);
                    String nextCoordString = "(" + nextCoords[0] + "," + nextCoords[1] + ")";

                    if (recordedCrashes.contains(nextCoordString) || outOfBoundsCoords.contains(nextCoordString)) {
                        continue;
                    }

                    Set<Colour> keysBeforeMove = new HashSet<>(FuzzerHelper.getLastState().keys);

                    boolean isCrash = false;
                    boolean isFailure = false;
                    char crashingMove = '\0';

                    try {
                        for (char nextMove : newSeq.toCharArray()) {
                            crashingMove = nextMove;
                            if (!applyMove(chip, nextMove)) {
                                isFailure = true;
                                break;
                            }
                        }
                    } catch (Exception e) {
                        int[] pastCoords = FuzzerHelper.getLocation();
                        int[] crashCoords = nextPos(pastCoords, crashingMove);
                        String line = crashCoords[0] + "," + crashCoords[1] + "," + e.getClass().getName();
                        if (recordedCrashes.add(line)) {
                            writer.write(line + System.lineSeparator());
                            writer.flush();
                        }
                        isCrash = true;
                    }

                    if (isCrash)
                        continue; // Go to the next moveChar in the inner loop

                    // 3. Handle non-crashing failure (isFailure = true)
                    if (isFailure) {
                        // Record out-of-bounds coords (if needed) and skip
                        int[] obCoords = FuzzerHelper.getLocation();
                        if (obCoords != null) {
                            outOfBoundsCoords.add("(" + obCoords[0] + "," + obCoords[1] + ")");
                        }
                        continue; // Go to the next moveChar in the inner loop
                    }

                    // 4. SUCCESS: Sequence led to a new reachable state.

                    // Get the final position and check if visited
                    int[] coords = FuzzerHelper.getLocation();
                    String coordString = "(" + coords[0] + "," + coords[1] + ")";

                    // Note: This is an extra check, but good for robustness
                    if (coords == null || visitedCoords.contains(coordString)) {
                        continue;
                    }

                    // State is new, so record it and queue the sequence for later expansion
                    visitedCoords.add(coordString);
                    sequences.add(newSeq);

                    // 5. Check for new keys collected by this sequence
                    Set<Colour> keysAfterMove = new HashSet<>(FuzzerHelper.getLastState().keys);

                    // Find newly collected keys (keysAfterMove - keysBeforeMove)
                    keysAfterMove.removeAll(keysBeforeMove);

                    if (!keysAfterMove.isEmpty()) {
                        for (Colour key : keysAfterMove) {
                            if (!keyLocations.containsKey(key)) {
                                keyLocations.put(key, coordString);
                            }
                        }
                        sequences.clear();
                        sequences.add(newSeq);
                        outOfBoundsCoords.clear();
                        visitedCoords.clear();
                        break;
                    }

                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static boolean applyMove(Chip chip, char moveChar) {
        switch (moveChar) {
            case 'U':
                return chip.moveUp();
            case 'D':
                return chip.moveDown();
            case 'L':
                return chip.moveLeft();
            case 'R':
                return chip.moveRight();
            default:
                throw new IllegalArgumentException("Invalid move: " + moveChar);
        }
    }

    private static int[] nextPos(int[] currentPos, char moveChar) {
        int x = currentPos[0];
        int y = currentPos[1];
        switch (moveChar) {
            case 'U':
                y--;
                break;
            case 'D':
                y++;
                break;
            case 'L':
                x--;
                break;
            case 'R':
                x++;
                break;
        }
        int[] nextPos = { x, y };
        return nextPos;
    }
}
