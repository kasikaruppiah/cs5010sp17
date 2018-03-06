import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by pdp-kasi05011992-somanshu on 3/24/17.
 *
 * The AllItineraries class defines static methods for the Flight type
 * In particular, it defines static methods for find itineraries from a
 * source airport to destination airport
 */

public class AllItineraries {
    /**
     * GIVEN:
     * @param ap1     String describing source airport
     * @param ap2     String describing destination airport
     * @param flights RacketList describing the list of flights
     *                a traveller is willing to consider taking
     * RETURNS:
     * @return an ArrayList of Itinerary describing the itineraries
     * a traveller might choose
     * STRATEGY:
     * combine simpler functions
     * HALTING MEASURE:
     * length of sortFlights(ap1, RacketLists.toArrayList(flights))
     */
    // EXAMPLES:
    //     findAllItineraries ("JFK", "JFK", FlightExamples.panAmFlights)
    //         =>  []
    //
    //     findAllItineraries ("LGA", "PDX", FlightExamples.deltaFlights)
    // =>  [[ [name = [Delta 0121] departs = [LGA] arrives = [MSP]
    //      departsAt = [hour = [11] minute = [0]]
    //      arrivesAt = [hour = [14] minute = [9]]]
    //      [name = [Delta 2163] departs = [MSP] arrives = [PDX]
    //      departsAt = [hour = [15] minute = [0]]
    //      arrivesAt = [hour = [19] minute = [2]]] ]
    //      flightTime = [482] arrivesAt = [hour = [19] minute = [2]]
    //      airports = [[LGA, MSP]]
    //     [ [name = [Delta 1422] departs = [LGA] arrives = [MSP]
    //      departsAt = [hour = [15] minute = [0]]
    //      arrivesAt = [hour = [18] minute = [22]]]
    //      [name = [Delta 1609] departs = [MSP] arrives = [DEN]
    //      departsAt = [hour = [20] minute = [35]]
    //      arrivesAt = [hour = [22] minute = [52]]]
    //      [name = [Delta 5743] departs = [DEN] arrives = [LAX]
    //      departsAt = [hour = [0] minute = [34]]
    //      arrivesAt = [hour = [3] minute = [31]]]
    //      [name = [Delta 2077] departs = [LAX] arrives = [PDX]
    //      departsAt = [hour = [17] minute = [35]]
    //      arrivesAt = [hour = [20] minute = [9]]] ]
    //      flightTime = [1749] arrivesAt = [hour = [20] minute = [9]]
    //      airports = [[LGA, MSP, DEN, LAX]]]
    public static ArrayList<Itinerary> findAllItineraries(
            String ap1, String ap2, RacketList<Flight> flights) {
        ArrayList<Flight> flightList = RacketLists.toArrayList(flights);
        ArrayList<Flight> sortedFlights = sortFlights(ap1, flightList);
        HashMap<String, ArrayList<Itinerary>> allItineraries =
                new HashMap<String, ArrayList<Itinerary>>();

        for (Flight flight : sortedFlights) {
            processFlight(allItineraries, flight);
        }

        ArrayList<Itinerary> itineraries = new ArrayList<Itinerary>();
        if (allItineraries.containsKey(ap2)) {
            itineraries = allItineraries.get(ap2);
        }

        return itineraries;
    }

    /**
     * GIVEN:
     * @param ap1     String describing the source airport
     * @param flights ArrayList describing the list of flights
     *                a traveller is willing to consider taking
     * RETURNS:
     * @return an ArrayList of flights a traveller is willing to consider
     * taking sorted based on the source airport
     * sorting done in BFS approach
     * STRATEGY:
     * combine simpler functions
     * HALTING MEASURE:
     * length of flights
     */
    // EXAMPLES:
    //     sortFlights ("JFK", FlightExamples.panAmFlights)
    //         =>  []
    //
    //     sortFlights ("LGA", FlightExamples.deltaFlightsSmall)
    // =>  [name = [Delta 5703] departs = [DEN] arrives = [LAX]
    //      departsAt = [hour = [14] minute = [4]]
    //      arrivesAt = [hour = [17] minute = [15]],
    //      name = [Delta 1601] departs = [DEN] arrives = [DTW]
    //      departsAt = [hour = [13] minute = [5]]
    //      arrivesAt = [hour = [16] minute = [11]],
    //      name = [Delta 2077] departs = [LAX] arrives = [PDX]
    //      departsAt = [hour = [17] minute = [35]]
    //      arrivesAt = [hour = [20] minute = [9]],
    //      name = [Delta 0249] departs = [DTW] arrives = [MSP]
    //      departsAt = [hour = [15] minute = [0]]
    //      arrivesAt = [hour = [17] minute = [7]],
    //      name = [Delta 1609] departs = [MSP] arrives = [DEN]
    //      departsAt = [hour = [20] minute = [35]]
    //      arrivesAt = [hour = [22] minute = [52]],
    //      name = [Delta 2163] departs = [MSP] arrives = [PDX]
    //      departsAt = [hour = [15] minute = [0]]
    //      arrivesAt = [hour = [19] minute = [2]]]
    private static ArrayList<Flight> sortFlights(String ap1,
                                                 ArrayList<Flight> flights) {
        HashMap<String, ArrayList<Flight>> flightMap =
                Flights.getFlightMap(flights);
        ArrayList<Flight> sortedFlights = new ArrayList<Flight>();
        ArrayList<String> processedAirports = new ArrayList<String>();
        ArrayList<String> remainingAirports = new ArrayList<String>();
        remainingAirports.add(ap1);

        while (!remainingAirports.isEmpty()) {
            String ap = remainingAirports.get(0);
            if (!processedAirports.contains(ap) && flightMap.containsKey(ap)) {
                for (Flight flight : flightMap.get(ap)) {
                    sortedFlights.add(flight);
                    String arrives = flight.arrives();
                    if (!processedAirports.contains(arrives) &&
                            !remainingAirports.contains(arrives)) {
                        remainingAirports.add(arrives);
                    }
                }
                processedAirports.add(ap);
            }
            remainingAirports.remove(0);
        }

        return sortedFlights;
    }

    /**
     * GIVEN:
     * @param hashMap a HashMap describing an airport and a ArrayList of
     *                Itinerary to get to that airport from the source airport
     * @param flight  a Flight
     * RETURNS:
     *                None; Updates the input HashMap with a new Itinerary that
     *                includes the input Flight
     * STRATEGY:
     * combine simpler functions
     */
    private static void processFlight(
            HashMap<String, ArrayList<Itinerary>> hashMap, Flight flight) {
        String departs = flight.departs();
        String arrives = flight.arrives();

        if (hashMap.containsKey(departs)) {
            ArrayList<Itinerary> nonCyclicItinerary =
                    Itineraries.nonCyclicItineraries(
                            hashMap.get(departs), arrives);
            if (!nonCyclicItinerary.isEmpty()) {
                ArrayList<Itinerary> newItineraries =
                        Itineraries.updateItineraries(
                                nonCyclicItinerary, flight);
                Itinerary fastestItinerary =
                        Itineraries.findFastestItinerary(newItineraries);
                addItinerary(hashMap, fastestItinerary, arrives);
            }
        } else {
            Itinerary newItinerary = makeNewItinerary(flight);
            addItinerary(hashMap, newItinerary, arrives);
        }
    }

    /**
     * GIVEN:
     * @param flight a Flight
     * RETURNS:
     * @return An Itinerary with the input Flight
     * STRATEGY:
     * combine simpler functions
     */
    // EXAMPLES:
    //     makeNewItinerary (Flights.make("Delta2163", "MSP", "PDX",
    //            UTCs.make(15, 0), UTCs.make(19, 2)))
    //         =>  [ [name = [Delta2163] departs = [MSP] arrives = [PDX]
    //              departsAt = [hour = [15] minute = [0]]
    //              arrivesAt = [hour = [19] minute = [2]]] ]
    //              flightTime = [242] arrivesAt = [hour = [19] minute = [2]]
    //              airports = [[MSP]]
    private static Itinerary makeNewItinerary(Flight flight) {
        ArrayList<Flight> itinerary = new ArrayList<Flight>();
        itinerary.add(flight);
        UTC arrivesAt = flight.arrivesAt();
        int flightTime = UTCs.timeDifference(flight.departsAt(), arrivesAt);
        ArrayList<String> airports = new ArrayList<String>();
        airports.add(flight.departs());

        return new Itinerary(itinerary, flightTime, arrivesAt, airports);
    }

    /**
     * GIVEN:
     * @param hashMap   a HashMap describing an airport and a ArrayList of
     *                  Itinerary to get to that airport from the source airport
     * @param itinerary an Itinerary representing
     * @param arrives   a String describing the destination airport
     *                  of the Itinerary
     * RETURNS:
     *                  None: updates the input HashMap with Itinerary
     * STRATEGY:
     * combine simpler functions
     */
    private static void addItinerary(
            HashMap<String, ArrayList<Itinerary>> hashMap,
            Itinerary itinerary,
            String arrives) {
        if (hashMap.containsKey(arrives)) {
            hashMap.get(arrives).add(itinerary);
        } else {
            ArrayList<Itinerary> itineraries = new ArrayList<Itinerary>();
            itineraries.add(itinerary);
            hashMap.put(arrives, itineraries);
        }
    }
}