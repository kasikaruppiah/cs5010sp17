/**
 * Created by pdp-kasi05011992-somanshu on 3/23/17.
 */
public class UTCsTest {
    private static void testMake() {
        assert UTCs.make(11, 00).equals(new DefaultUTC(11, 00)) :
                "Error in UTC creation";

    }

    private static void testTimeDifference() {
        assert UTCs.timeDifference(UTCs.make(11, 00), UTCs.make(15, 00)) ==
                240 : "Time difference is not correct";
        assert UTCs.timeDifference(UTCs.make(21, 00), UTCs.make(05, 00)) ==
                480 : "Time difference is not correct";
    }

    public static void testUTCs() {
        testMake();
        testTimeDifference();
    }

}