/**
 * Created by kasi on 3/26/17.
 */
class DefaultRacketListTest {
    private static RacketList<Flight> flight1 = RacketLists.empty().
            cons(Flights.make("Delta0121", "LGA", "MSP",
                    UTCs.make(11, 0), UTCs.make(14, 9)));
    private static RacketList<Flight> flight2 = RacketLists.empty().
            cons(Flights.make("Delta0121", "LGA", "MSP",
                    UTCs.make(11, 0), UTCs.make(14, 9))).
            cons(Flights.make("Delta0223", "LGA", "MSP",
                    UTCs.make(11, 0), UTCs.make(14, 9)));

    private static void testIsEmpty() {
        assert flight1.isEmpty() == false : "mismatch in empty check";
        assert RacketLists.empty().isEmpty() == true :
                "mismatch in empty check";
    }

    private static void testFirst() {
        assert flight2.first().equals(Flights.make("Delta0223", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9))) :
                "mismatch in first returned from racketlist";

        assert RacketLists.empty().first() == null :
                "mismatch in first returned from empty racketlist";
    }

    private static void testRest() {
        assert flight2.rest().equals(RacketLists.empty().
                cons(Flights.make("Delta0121", "LGA", "MSP",
                        UTCs.make(11, 0), UTCs.make(14, 9)))) :
                "mismatch in rest returned from racketlist";

        assert flight1.rest().equals(RacketLists.empty()) :
                "mismatch in rest returned from empty racketlist";

        assert RacketLists.empty().rest() == null :
                "mismatch in rest returned from empty racketlist";
    }

    private static void testCons() {
        assert flight1.cons(Flights.make("Delta0223", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9))).equals(flight2) :
                "mismatch in cons";
    }

    private static void testEquals() {
        assert flight1.equals(flight1) == true :
                "mismatch when same racketlist is compared";
        assert flight1.equals(null) == false :
                "mismatch when racketlist is compared with null";
        assert flight1.equals(new String()) == false :
                "mismatch when racketlist is compared with other object";
        assert flight1.equals(flight2) == false :
                "mismatch when different racketlists are compared";
    }

    public static void testDefaultRacketList() {
        testIsEmpty();
        testFirst();
        testRest();
        testCons();
        testEquals();
    }
}
