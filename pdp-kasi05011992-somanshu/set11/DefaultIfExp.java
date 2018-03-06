import java.util.Map;

/**
 * @author kasi
 *
 */

// Constructor template for DefaultIfExp:
// new DefaultIfExp (testPart, thenPart, elsePart)
// Interpretation:
// testPart is the condition part of the if exp
// thenPart is the part of the if exp for true condition
// elsePart is the part of the if exp for the false condition
public class DefaultIfExp extends AbstractExp implements IfExp {

	private Exp testPart; // the condition part of the if exp
	private Exp thenPart; // the part of the if exp for true condition
	private Exp elsePart; // the part of the if exp for the false condition

	/**
	 * Constructor for the DefaultIfExp
	 * 
	 * @param testPart
	 * @param thenPart
	 * @param elsePart
	 */
	public DefaultIfExp(Exp testPart, Exp thenPart, Exp elsePart) {
		this.testPart = testPart;
		this.thenPart = thenPart;
		this.elsePart = elsePart;
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
	 * @see AbstractExp#isIf()
	 */
	@Override
	public boolean isIf() {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#asIf()
	 */
	@Override
	public IfExp asIf() {
		return this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see IfExp#testPart()
	 */
	@Override
	public Exp testPart() {
		return testPart;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see IfExp#thenPart()
	 */
	@Override
	public Exp thenPart() {
		return thenPart;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see IfExp#elsePart()
	 */
	@Override
	public Exp elsePart() {
		return elsePart;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#value(java.util.Map)
	 */
	@Override
	public ExpVal value(Map<String, ExpVal> env) {
		if (testPart.value(env).asBoolean()) {
			return thenPart.value(env);
		} else {
			return elsePart.value(env);
		}
	}

}
