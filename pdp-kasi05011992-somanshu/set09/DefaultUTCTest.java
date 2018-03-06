/**
 * Created by kasi on 3/25/17.
 */
public class DefaultUTCTest {
    private static UTC t1 = new DefaultUTC(14, 9);
    private static UTC t2 = new DefaultUTC(11, 0);

    private static void testHour() {
        assert t1.hour() == 14 :
                "mismatch in hour returned from UTC object";
    }

    private static void testMinute() {
        assert t1.minute() == 9 :
                "mismatch in minute returned from UTC object";
    }

    private static void testIsEqual() {
        assert t1.isEqual(t1) == true :
                "mismatch in isEqual when same UTC object is compared";
    }

    private static void testEquals() {
        assert t1.equals(t1) == true :
                "mismatch in equals when same UTC object is compared";
        assert t1.equals(null) == false :
                "mismatch in equals when UTC object is compared with null";
        assert t1.equals(new String()) == false :
                "mismatch in equals when UTC object is compared with" +
                        " non UTC object";
        assert t1.equals(t2) == false :
                "mismatch in equals when 2 different UTC objects are compared";
    }

    public static void testDefaultUTC() {
        testHour();
        testMinute();
        testIsEqual();
        testEquals();
    }
}