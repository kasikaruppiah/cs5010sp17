import java.util.ArrayList;

/**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 */
public class ItinerariesTest {
    private static ArrayList<Itinerary> itineraries =
            AllItineraries.findAllItineraries(
                    "LGA", "PDX", FlightExamples.deltaFlights);

    private static void testNonCyclicItineraries() {
        ArrayList<Flight> flights = new ArrayList<Flight>();
        flights.add(Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        flights.add(Flights.make("Delta 2163", "MSP", "PDX",
                UTCs.make(15, 0), UTCs.make(19, 2)));
        ArrayList<String> airports = new ArrayList<String>();
        airports.add("LGA");
        airports.add("MSP");
        Itinerary itinerary = new Itinerary(flights, 482,
                UTCs.make(19, 2), airports);

        ArrayList<Itinerary> itineraries1 = new ArrayList<Itinerary>();
        itineraries1.add(itinerary);

        assert Itineraries.nonCyclicItineraries(itineraries, "BOS").
                equals(itineraries) : "Function does not " +
                "return correct List of Itinerary";
        assert Itineraries.nonCyclicItineraries(itineraries, "LAX").
                equals(itineraries1) : "Function does not " +
                "return correct List of Itinerary";
    }

    private static void testUpdateItineraries() {
        Flight flight1 = Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9));
        ArrayList<Flight> flights1 = new ArrayList<Flight>();
        flights1.add(flight1);
        ArrayList<String> airports1 = new ArrayList<String>();
        airports1.add("LGA");
        Itinerary itinerary1 = new Itinerary(flights1, 189,
                UTCs.make(14, 9), airports1);
        ArrayList<Itinerary> itineraries1 = new ArrayList<Itinerary>();
        itineraries1.add(itinerary1);

        Flight flight2 = Flights.make("Delta 2163", "MSP", "PDX",
                UTCs.make(15, 0), UTCs.make(19, 2));
        ArrayList<Flight> flights2 = new ArrayList<Flight>();
        flights2.add(flight1);
        flights2.add(flight2);
        ArrayList<String> airports2 = new ArrayList<String>();
        airports2.add("LGA");
        airports2.add("MSP");
        Itinerary itinerary2 = new Itinerary(flights2, 482,
                UTCs.make(19, 2), airports2);
        ArrayList<Itinerary> itineraries2 = new ArrayList<Itinerary>();
        itineraries2.add(itinerary2);

        assert Itineraries.updateItineraries(itineraries1, flight2).
                equals(itineraries2) : "Function does not " +
                "return correct List of Itinerary";
    }

    private static void testFindFastestItinerary() {
        ArrayList<Flight> flights = new ArrayList<Flight>();
        flights.add(Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        flights.add(Flights.make("Delta 2163", "MSP", "PDX",
                UTCs.make(15, 0), UTCs.make(19, 2)));
        ArrayList<String> airports = new ArrayList<String>();
        airports.add("LGA");
        airports.add("MSP");
        Itinerary itinerary = new Itinerary(flights, 482,
                UTCs.make(19, 2), airports);

        assert Itineraries.findFastestItinerary(itineraries).
                equals(itinerary) :
                "Function does not return the correct Itinerary";
    }

    public static void testItineraries() {
        testNonCyclicItineraries();
        testUpdateItineraries();
        testFindFastestItinerary();
    }
}