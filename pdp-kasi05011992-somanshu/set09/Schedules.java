import java.util.ArrayList;

/**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 *
 * The Schedules class defines static methods for the RacketList type
 * In particular it defines static methods to find if you can travel
 * between two airports, a method get the fastest itinerary between
 * two airports and a method to get the travel time between two airports
 */
public class Schedules {
    // GIVEN: the names of two airports, ap1 and ap2 (respectively),
    //     and a RacketList<Flight%gt; that describes all of the flights a
    //     traveller is willing to consider taking
    // RETURNS: true if and only if it is possible to fly from the
    //     first airport (ap1) to the second airport (ap2) using
    //     only the given flights
    // STRATEGY:
    // combine simpler functions
    // EXAMPLES:
    //     canGetThere ("06N", "JFK", FlightExamples.panAmFlights)  =>  false
    //     canGetThere ("JFK", "JFK", FlightExamples.panAmFlights)  =>  true
    //     canGetThere ("06N", "LAX", FlightExamples.deltaFlights)  =>  false
    //     canGetThere ("LAX", "06N", FlightExamples.deltaFlights)  =>  false
    //     canGetThere ("LGA", "PDX", FlightExamples.deltaFlights)  =>  true
    public static boolean canGetThere(String ap1,
                                      String ap2,
                                      RacketList<Flight> flights) {

        ArrayList<Itinerary> itineraries =
                AllItineraries.findAllItineraries(ap1, ap2, flights);

        return ap1.equals(ap2) || (!itineraries.isEmpty());
    }

    // GIVEN: the names of two airports, ap1 and ap2 (respectively),
    //     and a RacketList<Flight> that describes all of the flights a
    //     traveller is willing to consider taking
    // WHERE: it is possible to fly from the first airport (ap1) to
    //     the second airport (ap2) using only the given flights
    // RETURNS: a list of flights that tells how to fly from the
    //     first airport (ap1) to the second airport (ap2) in the
    //     least possible time, using only the given flights
    // NOTE: to simplify the problem, your program should incorporate
    //     the totally unrealistic simplification that no layover
    //     time is necessary, so it is possible to arrive at 1500
    //     and leave immediately on a different flight that departs
    //     at 1500
    // STRATEGY:
    // combine simpler functions
    // EXAMPLES:
    //     fastestItinerary ("JFK", "JFK", FlightExamples.panAmFlights)
    //         =>  RacketLists.empty()
    //
    //     fastestItinerary ("LGA", "PDX", FlightExamples.deltaFlights)
    // =>  RacketLists.empty().cons
    //         (Flights.make ("Delta 2163",
    //                        "MSP", "PDX",
    //                        UTCs.make (15, 0), UTCs.make (19, 2))).cons
    //             (Flights.make ("Delta 0121",
    //                            "LGA", "MSP",
    //                            UTCs.make (11, 0),
    //                            UTCs.make (14, 9)))
    //
    // (Note: The Java syntax for a method call makes those calls
    // to cons look backwards from what you're used to in Racket.)
    public static RacketList<Flight> fastestItinerary(
            String ap1,
            String ap2,
            RacketList<Flight> flights) {
        RacketList<Flight> racketList = RacketLists.empty();

        if (!ap1.equals(ap2)) {
            ArrayList<Itinerary> itineraries =
                    AllItineraries.findAllItineraries(ap1, ap2, flights);
            if (!itineraries.isEmpty()) {
                Itinerary itinerary =
                        Itineraries.findFastestItinerary(itineraries);
                racketList = RacketLists.toRacketList(itinerary.itinerary());
            }
        }

        return racketList;
    }

    // GIVEN: the names of two airports, ap1 and ap2 (respectively),
    //     and a RacketList<Flight> that describes all of the flights a
    //     traveller is willing to consider taking
    // WHERE: it is possible to fly from the first airport (ap1) to
    //     the second airport (ap2) using only the given flights
    // RETURNS: the number of minutes it takes to fly from the first
    //     airport (ap1) to the second airport (ap2), including any
    //     layovers, by the fastest possible route that uses only
    //     the given flights
    // STRATEGY:
    // combine simpler functions
    // EXAMPLES:
    //     travelTime ("JFK", "JFK", FlightExamples.panAmFlights)  =>  0
    //     travelTime ("LGA", "PDX", FlightExamples.deltaFlights)  =>  482
    public static int travelTime(String ap1,
                                 String ap2,
                                 RacketList<Flight> flights) {
        int travelTime = 0;

        if (!ap1.equals(ap2)) {
            ArrayList<Itinerary> itineraries =
                    AllItineraries.findAllItineraries(ap1, ap2, flights);
            if (!itineraries.isEmpty()) {
                Itinerary itinerary =
                        Itineraries.findFastestItinerary(itineraries);
                travelTime = itinerary.flightTime();
            }
        }

        return travelTime;
    }
}
