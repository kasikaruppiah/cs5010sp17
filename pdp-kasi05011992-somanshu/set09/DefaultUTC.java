import java.util.Objects;

/**
 * Created by pdp-kasi05011992-somanshu on 3/24/17.
 *
 // Constructor template for DefaultUTC:
 //     new DefaultUTC (h, m)
 // Interpretation:
 //     h is the UTC hour (between 0 and 23, inclusive)
 //     m is the UTC minute (between 0 and 59, inclusive)
 // Representation:
 //     Internally, the hour is represented in Eastern Standard Time,
 //     which is five hours behind UTC.
 */

public class DefaultUTC implements UTC {
    private int hour;
    private int minute;

    // the java constructor

    /**
     * GIVEN:
     * @param hour      an integer representing hour between 0 and 23
     * @param minute    an integer representing minute between 0 and 59
     * RETURNS:
     * an UTC with given details
     */
    public DefaultUTC(int hour, int minute) {
        this.hour = hour;
        this.minute = minute;
    }

    // Returns the hour, between 0 and 23 inclusive.
    @Override
    public int hour() {
        return hour;
    }

    // Returns the minute, between 0 and 59 inclusive.
    @Override
    public int minute() {
        return minute;
    }

    // Returns true iff the given UTC is equal to this UTC.
    @Override
    public boolean isEqual(UTC t2) {
        return (hour == t2.hour()) && (minute == t2.minute());
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj == null || !(obj instanceof UTC)) {
            return false;
        }
        UTC t2 = (UTC) obj;

        return isEqual(t2);
    }

    @Override
    public int hashCode() {
        return Objects.hash(hour, minute);
    }

    @Override
    public String toString() {
        return "hour = [" + hour + "] minute = [" + minute + "]";
    }
}
