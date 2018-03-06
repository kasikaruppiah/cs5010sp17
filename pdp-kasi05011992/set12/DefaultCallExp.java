import java.util.HashMap;
import java.util.InputMismatchException;
import java.util.List;
import java.util.Map;

/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Constructor template for DefaultCallExp:
// new DefaultCallExp (opt, args)
// Interpretation:
// opt is the expression for the function part of the call
// args is the list of argument expressions
public class DefaultCallExp extends AbstractExp implements CallExp {

	private Exp opt; // the expression for the function part of the call
	private List<Exp> args; // args is the list of argument expressions

	/**
	 * Constructor for the DefaultCallExp
	 * 
	 * @param opt
	 * @param args
	 */
	public DefaultCallExp(Exp opt, List<Exp> args) {
		this.opt = opt;
		this.args = args;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractAst#asExp()
	 */
	@Override
	public Exp asExp() {
		return this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#isCall()
	 */
	@Override
	public boolean isCall() {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#asCall()
	 */
	@Override
	public CallExp asCall() {
		return this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see CallExp#operator()
	 */
	@Override
	public Exp operator() {
		return opt;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see CallExp#arguments()
	 */
	@Override
	public List<Exp> arguments() {
		return args;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#value(java.util.Map)
	 */
	@Override
	public ExpVal value(Map<String, ExpVal> env) {
		ExpVal localExpVal = opt.value(env);
		if (localExpVal.isFunction()) {
			// if localExpVal is a function create a new enviroment and evaluate
			// the Exp
			FunVal localFunVal = localExpVal.asFunction();
			Map<String, ExpVal> newEnv = new HashMap<String, ExpVal>(
					localFunVal.environment());
			LambdaExp localLambdaExp = localFunVal.code();
			Exp localExp = localLambdaExp.body();
			List<String> formals = localLambdaExp.formals();

			if (args.size() != formals.size()) {
				// throw exception when the size of formals and args don't match
				throw new InputMismatchException(
						"Mismatch in number of formals and arguments");
			}

			for (int i = 0; i < formals.size(); i++) {
				newEnv.put(formals.get(i), args.get(i).value(env));
			}

			return localExp.value(newEnv);
		} else {
			return localExpVal;
		}
	}

}
