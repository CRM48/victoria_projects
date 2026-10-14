import nz.ac.vuw.jenz.chipschallenge.*;
import org.junit.jupiter.api.*;
import java.io.File;
import static org.junit.jupiter.api.Assertions.*;

public class GameTest {

    private static Game game = null;
    private Chip chip = null;

    @BeforeAll
    public static void setupGame() {
        game = new GameBuilder()
                .cells(0, 5, 0, 5)
                .cells(6, 10, 0, 5)
                .door(5, 2, Colour.RED)
                .key(3, 3, Colour.RED)
                .crash(1, 3)
                .crash(7, 4)
                .entry(0, 0)
                .exit(10, 4)
                .build();

        // write file for inspection
        File svg = new File("test1-game.svg");
        GameVisualiser.visualise(game, svg, true);
        System.out.println("game used for testing visualised and exported to " + svg.getAbsolutePath());

    }

    @AfterAll
    public static void teardownGame() {
        game = null;
    }

    @BeforeEach
    public void setupChip() {
        chip = new Chip(game);
    }

    @AfterEach
    public void teardownChip() {
        chip = null;
    }

    @Test
    public void testMoveRight() {
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertFalse(chip.moveRight());
    }

    @Test
    public void testMoveLeft() {
        assertFalse(chip.moveLeft());
    }

    @Test
    public void testMoveDown() {
        assertTrue(chip.moveDown());
        assertTrue(chip.moveDown());
        assertTrue(chip.moveDown());
        assertTrue(chip.moveDown());
        assertFalse(chip.moveDown());
    }

    @Test
    public void testMoveUp() {
        assertFalse(chip.moveUp());
    }

    @Test
    public void testAround() {
        assertTrue(chip.moveRight());
        assertTrue(chip.moveDown());
        assertTrue(chip.moveLeft());
        assertTrue(chip.moveUp());
    }

    @Test
    void testDoorWithoutKey() {
        assertTrue(chip.moveDown());
        assertTrue(chip.moveDown());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertFalse(chip.moveRight());
    }

    @Test
    void testDoorWithKey() {

        assertTrue(chip.moveDown());
        assertTrue(chip.moveDown());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());

        // pick up key
        assertTrue(chip.moveDown());
        assertTrue(chip.moveUp());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
    }

    @Test
    void testSeededCrash1() {
        assertTrue(chip.moveDown());
        assertTrue(chip.moveDown());
        assertTrue(chip.moveDown());
        assertThrows(IllegalStateException.class, () -> chip.moveRight());
    }

    @Test
    void testExit() {

        assertTrue(chip.moveDown());
        assertTrue(chip.moveDown());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());

        // pick up key
        assertTrue(chip.moveDown());
        assertTrue(chip.moveUp());

        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());
        assertTrue(chip.moveRight());

        assertTrue(chip.moveDown());
        assertTrue(chip.moveDown());

        assertThrows(GameOverException.class, () -> assertTrue(chip.moveRight()));

    }

}
