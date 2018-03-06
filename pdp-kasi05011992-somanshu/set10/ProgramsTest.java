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
				Asts.identifierExp("squareFunction"));
		Def def1 = Asts.def("ScopeeMain", Asts.lambdaExp(Asts.list("k"), exp1));
		Exp exp2 = Asts.arithmeticExp(Asts.identifierExp("k"), "TIMES",
				Asts.identifierExp("k"));
		Def def2 = Asts.def("SquareFunction",
				Asts.lambdaExp(Asts.list("k"), exp2));
		ExpVal result = Programs.run(Asts.list(def1, def2),
				Asts.list(Asts.expVal(k)));

		return result.asInteger();
	}

	/**
	 * Triggers the test
	 */
	public static void testRun() {
		assert factorial(5) == 120 : "Factorial test failed";
		System.out.println("Factorial Test Passed");
		assert testScope(7) == 50 : "Scope test failed";
		System.out.println("Scope Test Passed");
		System.out.println("All Test Passed");
	}

}
