import java.util.ArrayList;

/**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 */
public class ItineraryTest {
    private static void testIsLoop() {
        ArrayList<Flight> flights = new ArrayList<Flight>();
        flights.add(Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        ArrayList<String> airports = new ArrayList<String>();
        airports.add("LGA");
        Itinerary itinerary = new Itinerary(flights, 189,
                UTCs.make(14, 9), airports);

        assert itinerary.isLoop("LGA") == true :
                "Function should return true if itinerary contains depature" +
                        "from arrives instead of false";

        assert itinerary.isLoop("BOS") == false :
                "Function should return false if itinerary contains depature" +
                        "from arrives instead of true";
    }

    private static void testitinerary() {
        ArrayList<Flight> flights = new ArrayList<Flight>();
        flights.add(Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        ArrayList<String> airports = new ArrayList<String>();
        airports.add("LGA");
        Itinerary itinerary = new Itinerary(flights, 189,
                UTCs.make(14, 9), airports);

        assert itinerary.itinerary().equals(flights) :
                "Incorrect itinerary returned from object";
    }

    private static void testFlightTime() {
        ArrayList<Flight> flights = new ArrayList<Flight>();
        flights.add(Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        ArrayList<String> airports = new ArrayList<String>();
        airports.add("LGA");
        Itinerary itinerary = new Itinerary(flights, 189,
                UTCs.make(14, 9), airports);

        assert itinerary.flightTime() == 189 :
                "Incorrect flight time returned from object";
    }

    private static void testArrivesAt() {
        ArrayList<Flight> flights = new ArrayList<Flight>();
        flights.add(Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        ArrayList<String> airports = new ArrayList<String>();
        airports.add("LGA");
        Itinerary itinerary = new Itinerary(flights, 189,
                UTCs.make(14, 9), airports);

        assert itinerary.arrivesAt().equals(UTCs.make(14, 9)) :
                "Incorrect arrives at UTC returned from object";
    }

    private static void testAirports() {
        ArrayList<Flight> flights = new ArrayList<Flight>();
        flights.add(Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        ArrayList<String> airports = new ArrayList<String>();
        airports.add("LGA");
        Itinerary itinerary = new Itinerary(flights, 189,
                UTCs.make(14, 9), airports);

        assert itinerary.airports().equals(airports) :
                "Incorrect airports returned from object";
    }

    private static void testEquals() {
        ArrayList<Flight> flights1 = new ArrayList<Flight>();
        flights1.add(Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        ArrayList<String> airports1 = new ArrayList<String>();
        airports1.add("LGA");
        Itinerary itinerary1 = new Itinerary(flights1, 189,
                UTCs.make(14, 9), airports1);

        ArrayList<Flight> flights2 = new ArrayList<Flight>();
        flights2.add(Flights.make("Delta 0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        ArrayList<String> airports2 = new ArrayList<String>();
        airports2.add("MSP");
        Itinerary itinerary2 = new Itinerary(flights2, 189,
                UTCs.make(14, 9), airports2);

        assert itinerary1.equals(itinerary1) == true :
                "Same itinerary should return true when compared";

        assert itinerary1.equals(null) == false :
                "Itinerary should return false when compared with null";

        assert itinerary1.equals(new String()) == false : "Itinerary should" +
                " return false when compared with different object";

        assert itinerary1.equals(itinerary2) == false :
                "Different Itinerary should return false when compared";
    }

    public static void testItinerary() {
        testIsLoop();
        testitinerary();
        testFlightTime();
        testArrivesAt();
        testAirports();
        testEquals();
    }
}