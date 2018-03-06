import java.util.ArrayList;

/**
 * Created by pdp-kasi05011992-somanshu on 3/24/17.
 *
 * The Itineraries class defines static methods for ArrayList<Itinerary>
 * In particular for finding non cyclic itineraries, updating itineraries
 * and finding fastest itinerary
 */

public class Itineraries {
    /**
     * GIVEN:
     * @param itineraries an ArrayList of Itinerary
     * @param arrives     a destination airport
     * RETURNS:
     * @return an ArrayList of Itinerary that has no Flight taken from
     * the input airport
     * STRATEGY:
     * combine simpler functions
     * HALTING MEASURE:
     * length of itineraries
     */
    // EXAMPLES:
    //     ArrayList<Itinerary> i = new ArrayList<Itinerary>();
    //    i.add(AllItineraries.makeNewItinerary(
    //            Flights.make("Delta2163", "MSP", "PDX",
    //            UTCs.make(15, 0), UTCs.make(19, 2))));
    //   ArrayList<Itinerary> itineraries =
    //                      Itineraries.nonCyclicItineraries(i, "LGA");
    //
    //   => [[ [name = [Delta2163] departs = [MSP] arrives = [PDX]
    //      departsAt = [hour = [15] minute = [0]]
    //      arrivesAt = [hour = [19] minute = [2]]] ]
    //      flightTime = [242] arrivesAt = [hour = [19] minute = [2]]
    //      airports = [[MSP]]]
    public static ArrayList<Itinerary> nonCyclicItineraries(
            ArrayList<Itinerary> itineraries, String arrives) {
        ArrayList<Itinerary> nonCyclicItineraries = new ArrayList<Itinerary>();

        for (Itinerary itinerary : itineraries) {
            if (!itinerary.isLoop(arrives)) {
                nonCyclicItineraries.add(itinerary);
            }
        }

        return nonCyclicItineraries;
    }

    /**
     * GIVEN:
     * @param itineraries an ArrayList of Itinerary
     * @param flight      a Flight
     * RETURNS:
     * @return an ArrayList of Itinerary with new Flight updated to the input
     * ArrayList of Itinerary
     * STRATEGY:
     * combine simpler functions
     * HALTING MEASURE:
     * length of itineraries
     */
    // EXAMPLES:
    //     ArrayList<Itinerary> i = new ArrayList<Itinerary>();
    //     i.add(AllItineraries.makeNewItinerary(
    //             Flights.make("Delta2163", "MSP", "PDX",
    //                  UTCs.make(15, 0), UTCs.make(19, 2))));
    //  ArrayList<Itinerary> itineraries =
    //              Itineraries.nonCyclicItineraries(i, "LGA");
    //  ArrayList<Itinerary> upItinerary =
    //          Itineraries.updateItineraries(itineraries,
    //                                      Flights.make("Delta2163",
    //                                                  "LAX", "PDX",
    //                              UTCs.make(15, 0), UTCs.make(19, 2)));
    //
    //    =>  [[ [name = [Delta2163] departs = [MSP] arrives = [PDX]
    //          departsAt = [hour = [15] minute = [0]]
    //          arrivesAt = [hour = [19] minute = [2]]]
    //          [name = [Delta2163] departs = [LAX] arrives = [PDX]
    //          departsAt = [hour = [15] minute = [0]]
    //          arrivesAt = [hour = [19] minute = [2]]] ]
    //          flightTime = [1682] arrivesAt = [hour = [19] minute = [2]]
    //          airports = [[MSP, LAX]]]
    public static ArrayList<Itinerary> updateItineraries(
            ArrayList<Itinerary> itineraries, Flight flight) {
        ArrayList<Itinerary> newItineraries = new ArrayList<Itinerary>();

        for (Itinerary itinerary : itineraries) {
            ArrayList<Flight> newItinerary =
                    new ArrayList<Flight>(itinerary.itinerary());
            int flightTime = itinerary.flightTime();
            UTC arrivesAt = itinerary.arrivesAt();
            ArrayList<String> airports =
                    new ArrayList<String>(itinerary.airports());

            UTC departureTime = flight.departsAt();
            UTC arrivalTime = flight.arrivesAt();
            int airTime = UTCs.timeDifference(departureTime, arrivalTime);
            int layoverTime = UTCs.timeDifference(arrivesAt, departureTime);

            newItinerary.add(flight);
            flightTime += airTime + layoverTime;
            arrivesAt = arrivalTime;
            airports.add(flight.departs());

            newItineraries.add(new Itinerary(
                    newItinerary, flightTime, arrivesAt, airports));
        }

        return newItineraries;
    }

    /**
     * GIVEN:
     * @param itineraries An ArrayList of Itinerary
     * RETURNS:
     * @return an Itinerary fastest among the input ArrayList of Itinerary
     * STRATEGY:
     * combine simpler functions
     * HALTING MEASURE:
     * length of itineraries
     */
    // EXAMPLES:
    //     ArrayList<Itinerary> i = new ArrayList<Itinerary>();
    //      i.add(AllItineraries.makeNewItinerary(
    //                  Flights.make("Delta2163", "MSP", "PDX",
    //                      UTCs.make(15, 0), UTCs.make(19, 2))));
    //      i.add(AllItineraries.makeNewItinerary(
    //                  Flights.make("Delta2163",
    //                                  "LAX", "PDX",
    //                      UTCs.make(15, 0), UTCs.make(19, 2))));
    //     ArrayList<Itinerary> itineraries =
    //                  Itineraries.nonCyclicItineraries(i, "LGA");
    //     Itinerary fastItinerary =
    //                  Itineraries.findFastestItinerary(itineraries);
    //
    //  =>  [ [name = [Delta2163] departs = [MSP] arrives = [PDX]
    //      departsAt = [hour = [15] minute = [0]]
    //      arrivesAt = [hour = [19] minute = [2]]] ]
    //      flightTime = [242] arrivesAt = [hour = [19] minute = [2]]
    //      airports = [[MSP]]
    public static Itinerary findFastestItinerary(
            ArrayList<Itinerary> itineraries) {
        Itinerary fastestItinerary = itineraries.get(0);

        for (int i = 1; i < itineraries.size(); i++) {
            Itinerary temporaryItinerary = itineraries.get(i);
            if (temporaryItinerary.flightTime() <
                    fastestItinerary.flightTime()) {
                fastestItinerary = temporaryItinerary;
            }
        }

        return fastestItinerary;
    }
}