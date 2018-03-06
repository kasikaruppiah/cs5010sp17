import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Contains static methods to interpret the input and provide results
public class Programs {

	/**
	 * Evaluate the value of the input params
	 * 
	 * @param pgm
	 *            List of Def that constitute the program
	 * @param inputs
	 *            List of ExpVal, used as input for first Def
	 * @return an ExpVal after evaluating the pgm
	 */
	public static ExpVal run(List<Def> pgm, List<ExpVal> inputs) {
		Map<String, ExpVal> env = new HashMap<String, ExpVal>();
		for (Def def : pgm) {
			// loop through Def and add it to the environment
			if (def.rhs().isConstant()) {
				env.put(def.lhs(), def.rhs().asConstant().value());
			} else {
				env.put(def.lhs(), Asts.expVal(def.rhs().asLambda(), env));
			}
		}

		// Convert the List<ExpVal> to List<Exp>
		List<Exp> args = new ArrayList<Exp>();
		for (ExpVal expVal : inputs) {
			args.add(Asts.constantExp(expVal));
		}

		// evaluate the pgm using callExp
		return Asts.callExp(Asts.identifierExp(pgm.get(0).lhs()), args)
				.value(env);
	}

	// Runs the ps11 program found in the file named on the command line
	// on the integer inputs that follow its name on the command line,
	// printing the result computed by the program.
	// f

	// Example:
	//
	// % java Programs sieve.ps11 2 100
	// 25
	public static void main(String[] args) {
		if (args.length >= 2) {
			String pgm = Scanner.readPgm(args[0]);
			List<ExpVal> inputs = new ArrayList<ExpVal>();
			for (int i = 1; i < args.length; i++) {
				long input = Long.parseLong(args[i]);
				inputs.add(Asts.expVal(input));
			}
			ExpVal result = Scanner.runPgm(pgm, inputs);
			if (result.isBoolean()) {
				System.out.println(result.asBoolean());
			} else {
				System.out.println(result.asInteger());
			}
		} else {
			System.out.println(Scanner.usageMsg);
		}
	}

	// Reads the ps11 program found in the file named by the given string
	// and returns the set of all variable names that occur free within
	// the program.
	//
	// Examples:
	// Programs.undefined ("church.ps11") // returns an empty set
	// Programs.undefined ("bad.ps11") // returns { "x", "z" }
	//
	// where bad.ps11 is a file containing:
	//
	// f (x, y) g (x, y) (y, z);
	// g (z, y) if 3 > 4 then x else f
	public static Set<String> undefined(String filename) {
		Set<String> variables = new HashSet<String>();

		String filecontents = Scanner.readPgm(filename);
		List<Def> pgm = Scanner.parsePgm(filecontents);
		// Save the def lhs to use use with boundVariables
		Set<String> defIds = new HashSet<String>();
		for (Def def : pgm) {
			defIds.add(def.lhs());
		}

		for (Def def : pgm) {
			if (def.rhs().isConstant()) {
				// Constant Defn is boundVariable, so no processing necessary
				continue;
			} else {
				Set<String> boundVariables = new HashSet<String>(defIds);
				Set<String> freeVariables = new HashSet<String>();
				processExp(def.rhs(), boundVariables, freeVariables);
				variables.addAll(freeVariables);
			}
		}

		return variables;
	}

	/**
	 * Updates the boundVariables and freeVariables for the given exp
	 * 
	 * @param exp
	 *            an Expression that needs to be processed
	 * @param boundVariables
	 *            Set of String representing the boundVariables
	 * @param freeVariables
	 *            Set of String representing the freeVariables
	 */
	private static void processExp(Exp exp, Set<String> boundVariables,
			Set<String> freeVariables) {
		// Skipping ConstantExp as nothing needs to be updated
		if (exp.isIdentifier()) {
			String name = exp.asIdentifier().name();
			// Check if the name is present in boundVariables
			if (!boundVariables.contains(name)) {
				freeVariables.add(name);
			}
		} else if (exp.isLambda()) {
			LambdaExp localLambdaExp = exp.asLambda();
			// Create new bound variables which includes lambda formals and
			// process body
			Set<String> localBoundVariables = new HashSet<String>(
					boundVariables);
			localBoundVariables.addAll(localLambdaExp.formals());
			processExp(localLambdaExp.body(), localBoundVariables,
					freeVariables);
		} else if (exp.isArithmetic()) {
			ArithmeticExp localArithmeticExp = exp.asArithmetic();
			// process the left and right operand of the ArithmeticExp
			processExp(localArithmeticExp.leftOperand(), boundVariables,
					freeVariables);
			processExp(localArithmeticExp.rightOperand(), boundVariables,
					freeVariables);
		} else if (exp.isCall()) {
			CallExp localCallExp = exp.asCall();
			// process the operator and arguments of the CallExp
			List<Exp> localExpList = new ArrayList<Exp>();
			localExpList.add(localCallExp.operator());
			localExpList.addAll(localCallExp.arguments());
			for (Exp exp2 : localExpList) {
				processExp(exp2, boundVariables, freeVariables);
			}
		} else if (exp.isIf()) {
			IfExp localIfExp = exp.asIf();
			// process the testPart, thenPart and elsePart of the IfExp
			processExp(localIfExp.testPart(), boundVariables, freeVariables);
			processExp(localIfExp.thenPart(), boundVariables, freeVariables);
			processExp(localIfExp.elsePart(), boundVariables, freeVariables);
		}
	}

}
