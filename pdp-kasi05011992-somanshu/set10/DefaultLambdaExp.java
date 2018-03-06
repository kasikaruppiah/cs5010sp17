import java.util.List;
import java.util.Map;

/**
 * @author kasi
 *
 */

// Constructor template for DefaultIfExp:
// new DefaultIfExp (formals, body)
// Interpretation:
// formals is the formal parameters of this lambda expression
// body is the body of this lambda expression
public class DefaultLambdaExp extends AbstractExp implements LambdaExp {

	private List<String> formals; // the formal parameters of this lambda
									// expression
	private Exp body; // the body of this lambda expression

	/**
	 * Constructor for the DefaultLambdaExp
	 * 
	 * @param formals
	 * @param body
	 */
	public DefaultLambdaExp(List<String> formals, Exp body) {
		this.formals = formals;
		this.body = body;
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
	 * @see AbstractExp#isLambda()
	 */
	@Override
	public boolean isLambda() {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#asLambda()
	 */
	@Override
	public LambdaExp asLambda() {
		return this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see LambdaExp#formals()
	 */
	@Override
	public List<String> formals() {
		return formals;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see LambdaExp#body()
	 */
	@Override
	public Exp body() {
		return body;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#value(java.util.Map)
	 */
	@Override
	public ExpVal value(Map<String, ExpVal> env) {
		return body.value(env);
	}

}
