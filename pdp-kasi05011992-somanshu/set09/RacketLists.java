import java.util.ArrayList;

/**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 */

/*
 Constructor template for RacketLists:
    new RacketLists()
 Interpretation:
 creates a new RacketList object
 * */
public class RacketLists {
    /**
     * GIVEN:
     * None
     * RETURNS:
     * @return a RacketList object
     */
    // EXAMPLE:
    //RacketLists.empty()  ==>  null
    public static RacketList empty() {
        return new DefaultRacketList();
    }

    /**
     * GIVEN:
     * @param racketList a RacketList of type E
     * RETURNS:
     * @return an ArrayList of type E representing the RacketList entries
     * STRATEGY:
     * combine simpler functions
     * HALTING MEASURE:
     * length of racketList
     */
    // EXAMPLE:
    //RacketLists.toArrayList(RacketLists.empty().
    //                cons(Flights.make("Delta2163", "MSP", "PDX",
    //                        UTCs.make(15, 0), UTCs.make(19, 2))).
    //                cons(Flights.make("Delta0121", "LGA", "MSP",
    //                        UTCs.make(11, 0), UTCs.make(14, 9))))  ==>
    //[
    //	name = [Delta0121] departs = [LGA] arrives = [MSP]
    //	departsAt = [hour = [11] minute = [0]]
    //	arrivesAt = [hour = [14] minute = [9]],
    //	name = [Delta2163] departs = [MSP] arrives = [PDX]
    //	departsAt = [hour = [15] minute = [0]]
    //	arrivesAt = [hour = [19] minute = [2]]
    //]
    public static <E> ArrayList toArrayList(RacketList<E> racketList) {
        ArrayList<E> arrayList = new ArrayList<E>();

        while (!racketList.isEmpty()) {
            arrayList.add(racketList.first());
            racketList = racketList.rest();
        }

        return arrayList;
    }

    /**
     * GIVEN:
     * @param arrayList an ArrayList of type E
     * RETURNS:
     * @return a RacketList of type E representing the given ArrayList
     * STRATEGY:
     * combine simpler functions
     * HALTING MEASURE:
     * length of arrayList
     */
    // EXAMPLE:
    //RacketLists.toRacketList([
    //	name = [Delta0121] departs = [LGA] arrives = [MSP]
    //	departsAt = [hour = [11] minute = [0]]
    //	arrivesAt = [hour = [14] minute = [9]],
    //	name = [Delta2163] departs = [MSP] arrives = [PDX]
    //	departsAt = [hour = [15] minute = [0]]
    //	arrivesAt = [hour = [19] minute = [2]]])  ==>
    //RacketLists.empty().
    //                cons(Flights.make("Delta2163", "MSP", "PDX",
    //                        UTCs.make(15, 0), UTCs.make(19, 2))).
    //                cons(Flights.make("Delta0121", "LGA", "MSP",
    //                        UTCs.make(11, 0), UTCs.make(14, 9)))
    public static <E> RacketList<E> toRacketList(ArrayList<E> arrayList) {
        RacketList<E> racketList = RacketLists.empty();

        if (!arrayList.isEmpty()) {
            ArrayList<E> reverseArrayList = new ArrayList<E>();
            for (E e : arrayList) {
                reverseArrayList.add(0, e);
            }
            for (E e : reverseArrayList) {
                racketList = racketList.cons(e);
            }
        }

        return racketList;
    }

    /**
     * GIVEN:
     * @param racketList1 a RacketList of type E
     * @param racketList2 a RacketList of type E
     * RETURNS:
     * @return true if both RacketList are equal
     * STRATEGY:
     * combine simpler functions
     */
    // EXAMPLE:
    //RacketLists.isEqual(RacketLists.empty().
    //        cons(Flights.make("Delta0121", "LGA", "MSP",
    //                UTCs.make(11, 0), UTCs.make(14, 9))).
    //        cons(Flights.make("Delta2163", "MSP", "PDX",
    //                UTCs.make(15, 0), UTCs.make(19, 2))),
    //RacketLists.empty().
    //        cons(Flights.make("Delta0121", "LGA", "MSP",
    //                UTCs.make(11, 0), UTCs.make(14, 9))).
    //        cons(Flights.make("Delta2163", "MSP", "PDX",
    //                UTCs.make(15, 0), UTCs.make(19, 2))))  ==>  true
    public static <E> boolean isEqual(RacketList<E> racketList1,
                                      RacketList<E> racketList2) {
        while (!racketList1.isEmpty() && !racketList2.isEmpty()) {
            if (racketList1.first().equals(racketList2.first())) {
                racketList1 = racketList1.rest();
                racketList2 = racketList2.rest();
            } else {
                return false;
            }
        }

        return racketList1.isEmpty() && racketList2.isEmpty();
    }

    /**
     * GIVEN:
     * @param racketList a RacketList of type E
     * RETURNS:
     * @return a String representing the given RacketList
     */
    public static <E> String toString(RacketList<E> racketList) {
        String convertedString = "";

        while (!racketList.isEmpty()) {
            convertedString += racketList.first().toString();
            racketList = racketList.rest();
        }

        return convertedString;
    }
}
