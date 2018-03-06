import java.util.Objects;

/**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 *
 // Constructor template for DefaultUTC:
 //     new DefaultFlight (name, departs, arrives, departsAt, arrivesAt)
 // Interpretation:
 //     name is a String representing Flight name
 //     departs is a String representing departing airport
 //     arrives is a String representing arrival airport
 //     departsAt is a UTC representing departing time
 //     arrivesAt is a UTC representing arrival time
 */

public class DefaultFlight implements Flight {

    private String name;
    private String departs;
    private String arrives;
    private UTC departsAt;
    private UTC arrivesAt;

    // the java constructor

    /**
     * GIVEN:
     * @param name      String representing name of Flight
     * @param departs   String representing departing airport
     * @param arrives   String representing arrival airport
     * @param departsAt UTC representing departing UTC
     * @param arrivesAt UTC representing arrival UTC
     * RETURNS:
     * a Flight with given details
     */
    public DefaultFlight(String name,
                         String departs,
                         String arrives,
                         UTC departsAt,
                         UTC arrivesAt) {
        this.name = name;
        this.departs = departs;
        this.arrives = arrives;
        this.departsAt = departsAt;
        this.arrivesAt = arrivesAt;
    }

    // Returns the name of this flight.
    @Override
    public String name() {
        return name;
    }

    // Returns the name of the airport from which this flight departs.
    @Override
    public String departs() {
        return departs;
    }

    // Returns the name of the airport at which this flight arrives.
    @Override
    public String arrives() {
        return arrives;
    }

    // Returns the time at which this flight departs.
    @Override
    public UTC departsAt() {
        return departsAt;
    }

    // Returns the time at which this flight arrives.
    @Override
    public UTC arrivesAt() {
        return arrivesAt;
    }

    // Returns true iff this flight and the given flight
    //     have the same name
    //     depart from the same airport
    //     arrive at the same airport
    //     depart at the same time
    // and arrive at the same time
    @Override
    public boolean isEqual(Flight f2) {
        return (name.equals(f2.name())) &&
                (departs.equals(f2.departs())) &&
                (arrives.equals(f2.arrives())) &&
                (departsAt.isEqual(f2.departsAt())) &&
                (arrivesAt.isEqual(f2.arrivesAt()));
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj == null || !(obj instanceof Flight)) {
            return false;
        }
        Flight f2 = (Flight) obj;

        return isEqual(f2);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, departs, arrives, departsAt, arrivesAt);
    }

    @Override
    public String toString() {
        return "name = [" + name +
                "] departs = [" + departs +
                "] arrives = [" + arrives +
                "] departsAt = [" + departsAt.toString() +
                "] arrivesAt = [" + arrivesAt.toString() + "]";
    }
}