import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * @author pdp-kasi05011992-somanshu
 *
 */
public class ProgramsTest {

	/**
	 * @param n
	 *            long representing the input
	 * @return the factorial of input as long
	 */
	private static long factorial(long n) {
		Exp exp1 = Asts.arithmeticExp(Asts.identifierExp("n"), "MINUS",
				Asts.constantExp(Asts.expVal(1)));
		Exp call1 = Asts.callExp(Asts.identifierExp("fact"), Asts.list(exp1));
		Exp testPart = Asts.arithmeticExp(Asts.identifierExp("n"), "EQ",
				Asts.constantExp(Asts.expVal(0)));
		Exp thenPart = Asts.constantExp(Asts.expVal(1));
		Exp elsePart = Asts.arithmeticExp(Asts.identifierExp("n"), "TIMES",
				call1);
		Def def1 = Asts.def("fact", Asts.lambdaExp(Asts.list("n"),
				Asts.ifExp(testPart, thenPart, elsePart)));
		ExpVal result = Programs.run(Asts.list(def1),
				Asts.list(Asts.expVal(n)));

		return result.asInteger();
	}

	/**
	 * @param k
	 *            long representing the input
	 * @return a long after evaluating code for given k
	 */
	private static long testScope(long k) {
		Exp exp1 = Asts.arithmeticExp(Asts.identifierExp("k"), "PLUS",
				Asts.callExp(Asts.identifierExp("SquareFunction"),
						Asts.list(Asts.identifierExp("k"))));
		Def def1 = Asts.def("ScopeMain", Asts.lambdaExp(Asts.list("k"), exp1));
		Exp exp2 = Asts.arithmeticExp(Asts.identifierExp("k"), "TIMES",
				Asts.identifierExp("k"));
		Def def2 = Asts.def("SquareFunction",
				Asts.lambdaExp(Asts.list("k"), exp2));
		ExpVal result = Programs.run(Asts.list(def1, def2),
				Asts.list(Asts.expVal(k)));

		return result.asInteger();
	}

	/**
	 * Triggers the run method test
	 */
	private static void testRun() {
		System.out.println("Testing Programs.run Method");
		assert factorial(5) == 120 : "Factorial test failed";
		System.out.println("Factorial Test Passed");
		assert testScope(7) == 56 : "Scope test failed";
		System.out.println("Scope Test Passed");
		System.out.println("All Programs.run Tests Passed");
	}

	/**
	 * Triggers the undefined method test
	 */
	private static void testUndefined() {
		System.out.println("Testing Programs.undefined Method");
		assert Programs.undefined("church.ps11")
				.equals(new HashSet<String>()) : "church.ps11 test failed";
		System.out.println("church.ps11 Test Passed");
		Set<String> output1 = new HashSet<String>(Arrays.asList("x", "z"));
		assert Programs.undefined("bad.ps11")
				.equals(output1) : "bad.ps11 test failed";
		System.out.println("bad.ps11 Test Passed");
		Set<String> output2 = new HashSet<String>(Arrays.asList("y"));
		assert Programs.undefined("piazza1.ps11")
				.equals(output2) : "piazza1.ps11 test failed";
		System.out.println("piazza1.ps11 Test Passed");
		assert Programs.undefined("piazza2.ps11")
				.equals(new HashSet<String>()) : "piazza2.ps11 test failed";
		System.out.println("piazza2.ps11 Test Passed");
		Set<String> output3 = new HashSet<String>(Arrays.asList("i", "x"));
		assert Programs.undefined("scope.ps11")
				.equals(output3) : "scope.ps11 test failed";
		System.out.println("scope.ps11 Test Passed");
		assert Programs.undefined("bst.ps11")
				.equals(new HashSet<String>()) : "bst.ps11 test failed";
		System.out.println("bst.ps11 Test Passed");
		System.out.println("All Programs.undefined Tests Passed");
	}

	public static void testPrograms() {
		testRun();
		testUndefined();
	}

}
