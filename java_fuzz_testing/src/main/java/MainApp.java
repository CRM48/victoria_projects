import java.io.File;

import nz.ac.vuw.jenz.chipschallenge.Colour;
import nz.ac.vuw.jenz.chipschallenge.Game;
import nz.ac.vuw.jenz.chipschallenge.GameBuilder;
import nz.ac.vuw.jenz.chipschallenge.GameVisualiser;

public class MainApp {
    public static void main(String[] args) {
        System.out.println("Starting game execution...");
        AgentAttacher.attachAgent("target/fuzz-agent.jar");
        Game game = (new GameBuilder()).cells(0, 10, 0, 10).cells(11, 20, 0, 10).cells(21, 30, 0, 10)
                .cells(0, 10, 11, 20).cells(11, 30, 11, 20).door(20, 3, Colour.GREEN).door(3, 10, Colour.BLUE)
                .door(10, 5, Colour.RED).door(10, 15, Colour.YELLOW).key(3, 3, Colour.RED).key(15, 7, Colour.BLUE)
                .key(6, 17, Colour.YELLOW).key(29, 19, Colour.GREEN).crash(7, 7).crash(25, 6).crash(6, 6).crash(11, 7)
                .crash(25, 8).crash(16, 13).entry(0, 0).exit(30, 9).build();
        File resultFile = new File("crashes.csv");
        File svg = new File("game-image.svg");
        GameVisualiser.visualise(game, svg, true);
        Fuzzer.run(game, resultFile);

        System.out.println("Game execution finished.");
    }

}
