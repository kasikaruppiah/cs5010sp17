import java.util.ArrayList;

/**
 * Created by kasi on 3/25/17.
 */
public class Benchmark {
    public static void benchmark(int n) {
        RacketList<Flight> flights = makeStressTest(n);
        long startTime = System.currentTimeMillis();
        ArrayList<String> airports = allAirports(n);
        for (String ap1 : airports) {
            for (String ap2 : airports) {
                int time = -1;
                if (Schedules.canGetThere(ap1, ap2, flights)) {
                    time = Schedules.travelTime(ap1, ap2, flights);
                }
                //System.out.println(ap1 + " => " + ap2 + " = " + time);
            }
        }
        long stopTime = System.currentTimeMillis();
        long elapsedTime = stopTime - startTime;
        System.out.println("n = [" + n +
                "] elapsedTime = [" + elapsedTime + "]");
    }

    private static RacketList<Flight> makeStressTest(int n) {
        RacketList<Flight> flights = RacketLists.empty();
        for (int i = n; i > 0; i--) {
            String name1 = "NoWays " + (i + i);
            String name2 = "NoWays " + (i + i + 1);
            String ap1 = "AP" + i;
            String ap2 = "AP" + (i + 1);
            UTC t1 = UTCs.make((107 * i) % 24, (223 * i) % 60);
            UTC t2 = UTCs.make((151 * i) % 24, (197 * i) % 60);
            UTC t3 = UTCs.make((163 * i) % 24, (201 * i) % 60);
            UTC t4 = UTCs.make((295 * i) % 24, (183 * i) % 60);
            Flight f1 = Flights.make(name1, ap1, ap2, t1, t2);
            Flight f2 = Flights.make(name2, ap1, ap2, t3, t4);
            flights = flights.cons(f1).cons(f2);
        }
        return flights;
    }

    private static ArrayList<String> allAirports(int n) {
        ArrayList<String> airports = new ArrayList<String>();
        for (int i = n + 1; i > 0; i--) {
            airports.add("AP" + i);
        }
        return airports;
    }

    public static void benchmarkRange(int start, int end, int step) {
        while (start <= end) {
            benchmark(start);
            start += step;
        }
    }
}