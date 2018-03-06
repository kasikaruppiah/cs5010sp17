import java.util.ArrayList;

/**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 */
public class AllItinerariesTest {
    private static void testFindAllItineraries() {
        ArrayList<Flight> flights1 = new ArrayList<Flight>();
        flights1.add(Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        flights1.add(Flights.make("Delta 2163", "MSP", "PDX",
                UTCs.make(15, 0), UTCs.make(19, 2)));
        ArrayList<String> airports1 = new ArrayList<String>();
        airports1.add("LGA");
        airports1.add("MSP");
        Itinerary itinerary1 = new Itinerary(flights1, 482,
                UTCs.make(19, 2), airports1);

        ArrayList<Flight> flights2 = new ArrayList<Flight>();
        flights2.add(Flights.make("Delta 1422", "LGA", "MSP",
                UTCs.make(15, 0), UTCs.make(18, 22)));
        flights2.add(Flights.make("Delta 1609", "MSP", "DEN",
                UTCs.make(20, 35), UTCs.make(22, 52)));
        flights2.add(Flights.make("Delta 5743", "DEN", "LAX",
                UTCs.make(0, 34), UTCs.make(3, 31)));
        flights2.add(Flights.make("Delta 2077", "LAX", "PDX",
                UTCs.make(17, 35), UTCs.make(20, 9)));
        ArrayList<String> airports2 = new ArrayList<String>();
        airports2.add("LGA");
        airports2.add("MSP");
        airports2.add("DEN");
        airports2.add("LAX");
        Itinerary itinerary2 = new Itinerary(flights2, 1749,
                UTCs.make(20, 9), airports2);

        ArrayList<Itinerary> arrayList = new ArrayList<Itinerary>();
        arrayList.add(itinerary1);
        arrayList.add(itinerary2);

        assert AllItineraries.findAllItineraries(
                "LGA", "PDX", FlightExamples.deltaFlights).equals(arrayList) :
                "Function does not returns the correct List of Itineraries";
    }

    public static void testAllItineraries() {
        testFindAllItineraries();
    }
}