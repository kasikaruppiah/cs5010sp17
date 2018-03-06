import java.util.ArrayList;
import java.util.Objects;

/**
 * Created by pdp-kasi05011992-somanshu on 3/24/17.
 *
 * Constructor template for Itinerary:
 *   new Itinerary()
 * <p>
 * Interpretation: An Itinerary represents a ArrayList of Flight,
 * int flightTime, UTC arrival time of the Itinerary and an ArrayList
 * of String representing all airports that are covered by the Itinerary
 */
public class Itinerary {

    private ArrayList<Flight> itinerary = new ArrayList<Flight>();
    private int flightTime;
    private UTC arrivesAt;
    private ArrayList<String> airports = new ArrayList<String>();

    public Itinerary(ArrayList<Flight> itinerary,
                     int flightTime,
                     UTC arrivesAt,
                     ArrayList<String> airports) {
        this.itinerary = itinerary;
        this.flightTime = flightTime;
        this.arrivesAt = arrivesAt;
        this.airports = airports;
    }

    /**
     * GIVEN:
     * @param arrives a String describing an airport
     * RETURNS:
     * @return a boolean value, true if the ArrayList of String
     *         containing the airports contain the input airport
     */
    public boolean isLoop(String arrives) {
        return airports.contains(arrives);
    }

    // Returns the ArrayList of Flight
    public ArrayList<Flight> itinerary() {
        return itinerary;
    }

    // Returns the total flight time of the Itinerary
    public int flightTime() {
        return flightTime;
    }

    // Returns the UTC of the last flight arrivesAt in the Itinerary
    public UTC arrivesAt() {
        return arrivesAt;
    }

    // Returns an ArrayList of String representing the airports
    public ArrayList<String> airports() {
        return airports;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj == null || !(obj instanceof Itinerary)) {
            return false;
        }
        Itinerary i2 = (Itinerary) obj;

        return itinerary.equals(i2.itinerary()) &&
                flightTime == i2.flightTime() &&
                arrivesAt.equals(i2.arrivesAt()) &&
                airports.equals(i2.airports());
    }

    @Override
    public int hashCode() {
        return Objects.hash(itinerary, flightTime, arrivesAt, airports);
    }

    @Override
    public String toString() {
        String convertedString = "[ ";

        for (Flight flight : itinerary) {
            convertedString += "[" + flight.toString() + "]";
        }

        convertedString += " ] flightTime = [" + flightTime +
                "] arrivesAt = [" + arrivesAt.toString() +
                "] airports = [" + airports.toString() + "]";

        return convertedString;
    }
}