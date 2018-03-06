/**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 */
public class SchedulesTest {
    private static void testCanGetThere() {
        assert Schedules.canGetThere(
                "LGA", "PDX", FlightExamples.deltaFlights) == true :
                "Function should return true " +
                        "if there is flight path between ap1 and ap2," +
                        " instead of returning false";

        assert Schedules.canGetThere(
                "LGA", "PDX", FlightExamples.panAmFlights) == false :
                "Function should return false " +
                        "if there is no flight path between ap1 and ap2," +
                        " instead of returning true";

        assert Schedules.canGetThere(
                "LGA", "LGA", FlightExamples.panAmFlights) == true :
                "Same airport should return true";
    }

    private static void testFastestItinerary() {
        RacketList<Flight> fastestPath = new DefaultRacketList<Flight>();
        fastestPath = RacketLists.empty().
                cons(Flights.make("Delta 2163", "MSP", "PDX",
                        UTCs.make(15, 0), UTCs.make(19, 2))).
                cons(Flights.make("Delta 0121", "LGA", "MSP",
                        UTCs.make(11, 0), UTCs.make(14, 9)));

        assert Schedules.fastestItinerary(
                "LGA", "PDX", FlightExamples.deltaFlights).equals(fastestPath) :
                "Function does not returns the fastest path from ap1 to ap2";

        assert Schedules.fastestItinerary(
                "JFK", "JFK", FlightExamples.panAmFlights).equals(
                RacketLists.empty()) : "Fastest Itinerary should" +
                " return empty";
    }

    private static void testTravelTime() {
        assert Schedules.travelTime(
                "LGA", "PDX", FlightExamples.deltaFlights) == 482 :
                "Function does not returns the fastest time between ap1 and ap2";
        assert Schedules.travelTime(
                "JFK", "JFK", FlightExamples.panAmFlights) == 0 :
                "Function does not returns the fastest time between ap1 and ap2";
    }

    public static void testSchedules() {
        testCanGetThere();
        testFastestItinerary();
        testTravelTime();
    }
}