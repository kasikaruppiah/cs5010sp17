import java.util.ArrayList;

/**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 */
public class RacketListsTest {
    private static void testEmpty() {
        assert RacketLists.empty().equals(new DefaultRacketList()) :
                "Function does not return null";
    }

    private static void testToArrayList() {
        ArrayList<Flight> flights = new ArrayList<Flight>();
        flights.add(Flights.make("Delta0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        flights.add(Flights.make("Delta2163", "MSP", "PDX",
                UTCs.make(15, 0), UTCs.make(19, 2)));

        assert RacketLists.toArrayList(RacketLists.empty().
                cons(Flights.make("Delta2163", "MSP", "PDX",
                        UTCs.make(15, 0), UTCs.make(19, 2))).
                cons(Flights.make("Delta0121", "LGA", "MSP",
                        UTCs.make(11, 0), UTCs.make(14, 9)))).
                equals(flights) :
                "Function does not return correct ArrayList";
    }

    private static void testToRacketList() {
        ArrayList<Flight> arrayList = new ArrayList<Flight>();
        arrayList.add(Flights.make("Delta0121", "LGA", "MSP",
                UTCs.make(11, 0), UTCs.make(14, 9)));
        arrayList.add(Flights.make("Delta2163", "MSP", "PDX",
                UTCs.make(15, 0), UTCs.make(19, 2)));
        assert RacketLists.toRacketList(arrayList).
                equals(RacketLists.empty().
                        cons(Flights.make("Delta2163", "MSP", "PDX",
                                UTCs.make(15, 0), UTCs.make(19, 2))).
                        cons(Flights.make("Delta0121", "LGA", "MSP",
                                UTCs.make(11, 0), UTCs.make(14, 9)))) :
                "Function does not return correct RacketList";
    }

    private static void testIsEqual() {
        assert RacketLists.isEqual(RacketLists.empty().
                        cons(Flights.make("Delta0121", "LGA", "MSP",
                                UTCs.make(11, 0), UTCs.make(14, 9))).
                        cons(Flights.make("Delta2163", "MSP", "PDX",
                                UTCs.make(15, 0), UTCs.make(19, 2))),
                RacketLists.empty().
                        cons(Flights.make("Delta0121", "LGA", "MSP",
                                UTCs.make(11, 0), UTCs.make(14, 9))).
                        cons(Flights.make("Delta2163", "MSP", "PDX",
                                UTCs.make(15, 0), UTCs.make(19, 2)))) == true :
                "Function should return true for equal RacketList instead of false";

        assert RacketLists.isEqual(RacketLists.empty().
                        cons(Flights.make("Delta0121", "LGA", "MSP",
                                UTCs.make(11, 0), UTCs.make(14, 9))).
                        cons(Flights.make("Delta2163", "MSP", "PDX",
                                UTCs.make(15, 0), UTCs.make(19, 2))),
                RacketLists.empty().
                        cons(Flights.make("Delta0121", "LGA", "MSP",
                                UTCs.make(11, 0), UTCs.make(14, 9))).
                        cons(Flights.make("Delta2163", "MSP", "DEN",
                                UTCs.make(15, 0), UTCs.make(19, 2)))) == false :
                "Function should return false for Unequal RacketList instead of true";
    }

    public static void testRacketLists() {
        testEmpty();
        testToArrayList();
        testToRacketList();
        testIsEqual();
    }
}