/**
 * Created by kasi on 3/24/17.
 */
public class Main {
    public static void main(String[] args) {
        runAllTests();
        Benchmark.benchmarkRange(10, 50, 2);
    }

    public static void runAllTests() {
        DefaultUTCTest.testDefaultUTC();
        DefaultFlightTest.testDefaultFlight();
        DefaultRacketListTest.testDefaultRacketList();
        UTCsTest.testUTCs();
        FlightsTest.testFlights();
        RacketListsTest.testRacketLists();
        ItineraryTest.testItinerary();
        ItinerariesTest.testItineraries();
        AllItinerariesTest.testAllItineraries();
        SchedulesTest.testSchedules();
    }
}
