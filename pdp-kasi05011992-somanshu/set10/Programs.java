import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

}
