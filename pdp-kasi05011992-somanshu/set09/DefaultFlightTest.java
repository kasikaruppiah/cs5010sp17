/**
 * Created by kasi on 3/25/17.
 */
public class DefaultFlightTest {
    private static Flight f1 = Flights.make("Delta 0121", "LGA", "MSP",
            UTCs.make(11, 0), UTCs.make(14, 9));
    private static Flight f2 = Flights.make("Delta 1609", "MSP", "DEN",
            UTCs.make(20, 35), UTCs.make(22, 52));

    private static void testName() {
        assert f1.name().equals("Delta 0121") :
                "mismatch in name returned from Flight object";
    }

    private static void testDeparts() {
        assert f1.departs().equals("LGA") :
                "mismatch in departs returned from Flight object";
    }

    private static void testArrives() {
        assert f1.arrives().equals("MSP") :
                "mismatch in arrives returned from Flight object";
    }

    private static void testDepartsAt() {
        assert f1.departsAt().equals(UTCs.make(11, 0)) :
                "mismatch in departsAt returned from Flight object";
    }

    private static void testArrivesAt() {
        assert f1.arrivesAt().equals(UTCs.make(14, 9)) :
                "mismatch in arrivesAt returned from Flight object";
    }

    private static void testIsEqual() {
        assert f1.isEqual(f1) == true : "mismatch in equals test";
    }

    private static void testEquals() {
        assert f1.equals(f1) == true : "mismatch in equals test";
        assert f1.equals(null) == false : "mismatch in equals test";
        assert f1.equals(new String()) == false : "mismatch in equals test";
        assert f1.equals(f2) == false : "mismatch in equals test";
    }

    public static void testDefaultFlight() {
        testName();
        testDeparts();
        testArrives();
        testDepartsAt();
        testArrivesAt();
        testIsEqual();
        testEquals();
    }
}