import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by pdp-kasi05011992-somanshu on 3/24/17.
 *
 * The Flights class defines static methods for the Flight
 * It defines a static factory method for creating Flight and
 * another method to create HashMap from input ArrayList Flight
 */

public class Flights {
    /**
     * GIVEN:
     * @param name      String describing the name of the Flight
     * @param departs   String describing the name of the departing airport
     * @param arrives   String describing the name of the arrival airport
     * @param departsAt UTC describing the departing time
     * @param arrivesAt UTC describing the arrival time
     * RETURNS:
     * @return a Flight object representing the input information
     */
    // EXAMPLE:
    //Flights.make("Delta2163", "MSP", "PDX",
    //                   UTCs.make(15, 0), UTCs.make(19, 2))  ==>
    //name = [Delta2163] departs = [MSP] arrives = [PDX]
    // departsAt = [hour = [15] minute = [0]]
    // arrivesAt = [hour = [19] minute = [2]]
    public static Flight make(String name,
                              String departs,
                              String arrives,
                              UTC departsAt,
                              UTC arrivesAt) {
        return new DefaultFlight(name, departs, arrives, departsAt, arrivesAt);
    }

    /**
     * GIVEN:
     * @param flights an ArrayList of Flight
     * RETURNS:
     * @return an HashMap containing an ArrayList of Flight departing from
     * each airport
     * STRATEGY:
     * combine simpler functions
     * HALTING MEASURE:
     * length of flights
     */
    // EXAMPLE:
    //Flights.getFlightMap(RacketLists.toArrayList(RacketLists.empty().
    //                cons(Flights.make("Delta2163", "MSP", "PDX",
    //                        UTCs.make(15, 0), UTCs.make(19, 2))).
    //                cons(Flights.make("Delta0121", "LGA", "MSP",
    //                        UTCs.make(11, 0), UTCs.make(14, 9))))) ==>
    //{
    //    LGA=[name = [Delta0121] departs = [LGA] arrives = [MSP]
    //    departsAt = [hour = [11] minute = [0]]
    //    arrivesAt = [hour = [14] minute = [9]]],
    //    MSP=[name = [Delta2163] departs = [MSP] arrives = [PDX]
    //    departsAt = [hour = [15] minute = [0]]
    //    arrivesAt = [hour = [19] minute = [2]]]
    //}
    public static HashMap<String, ArrayList<Flight>> getFlightMap(
            ArrayList<Flight> flights) {
        HashMap<String, ArrayList<Flight>> flightMap =
                new HashMap<String, ArrayList<Flight>>();

        for (Flight flight : flights) {
            String departs = flight.departs();
            if (flightMap.containsKey(departs)) {
                flightMap.get(departs).add(flight);
            } else {
                ArrayList<Flight> localFlights = new ArrayList<Flight>();
                localFlights.add(flight);
                flightMap.put(departs, localFlights);
            }
        }

        return flightMap;
    }
}
