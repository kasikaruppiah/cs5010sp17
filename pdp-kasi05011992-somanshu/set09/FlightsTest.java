import java.util.ArrayList;
import java.util.HashMap;

/**
 * /**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 */
public class FlightsTest {
    private static void testMake() {
        assert Flights.make("Delta0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)).
                equals(new DefaultFlight("Delta0121", "LGA", "MSP",
                        UTCs.make(11, 0), UTCs.make(14, 9))) :
                "Function does not return correct Flight";
    }

    private static void testGetFlightMap() {
        ArrayList<Flight> arrayList = new ArrayList<Flight>();
        arrayList.add(Flights.make("Delta0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        arrayList.add(Flights.make("Delta2163", "MSP", "PDX",
                UTCs.make(15, 0), UTCs.make(19, 2)));

        HashMap<String, ArrayList<Flight>> flightMap =
                new HashMap<String, ArrayList<Flight>>();
        flightMap.put("LGA", new ArrayList<Flight>(arrayList.subList(0, 1)));
        flightMap.put("MSP", new ArrayList<Flight>(arrayList.subList(1, 2)));
        assert Flights.getFlightMap(arrayList).
                equals(flightMap) :
                "Function does not return correct HashMap of the flights";
    }

    public static void testFlights() {
        testMake();
        testGetFlightMap();
    }
}