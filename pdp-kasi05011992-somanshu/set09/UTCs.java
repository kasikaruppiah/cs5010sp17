/**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 */

public class UTCs {
    /**
     * GIVEN:
     * @param hour   an int representing hour
     * @param minute an int representing minute
     *               RETURNS:
     * @return an UTC object with the input information
     */
    // EXAMPLE:
    // UTCs.make(14,9)  ==>  hour = [14] minute = [9]
    public static UTC make(int hour, int minute) {
        return new DefaultUTC(hour, minute);
    }

    /**
     * GIVEN:
     * @param utc1 an UTC
     * @param utc2 an UTC
     *             RETURNS:
     * @return an int representing the difference between
     * utc1 and utc2 in minutes
     * STRATEGY:
     * combine simpler functions
     */
    // EXAMPLE:
    //UTCs.timeDifference(UTCs.make(11, 00), UTCs.make(15, 00))  ==>  240
    public static int timeDifference(UTC utc1, UTC utc2) {
        return 60 * hoursBetween(utc1, utc2) + utc2.minute() - utc1.minute();
    }

    /**
     * GIVEN:
     * @param utc1 an UTC
     * @param utc2 an UTC
     * RETURNS:
     * @return an int representing the hours difference between utc1 and utc2
     * STRATEGY:
     * combine simpler functions
     */
    // EXAMPLE:
    //UTCs.hoursBetween(UTCs.make(11, 00), UTCs.make(15, 00))  ==>  4
    private static int hoursBetween(UTC utc1, UTC utc2) {
        return (previousDay(utc1, utc2) ?
                utc2.hour() + 24 :
                utc2.hour()) - utc1.hour();
    }

    /**
     * GIVEN:
     * @param utc1 an UTC
     * @param utc2 an UTC
     * RETURNS:
     * @return true if utc1 is from previous day of utc2
     * STRATEGY:
     * combine simpler functions
     */
    // EXAMPLE:
    //UTCs.previousDay(UTCs.make(11, 00), UTCs.make(15, 00))  ==>  false
    private static boolean previousDay(UTC utc1, UTC utc2) {
        return utc1.hour() > utc2.hour() ||
                (utc1.hour() == utc2.hour() &&
                        utc1.minute() >= utc2.minute());
    }
}
