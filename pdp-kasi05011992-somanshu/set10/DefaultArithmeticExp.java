import java.util.Map;

/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Constructor template for DefaultArithmeticExp:
// new DefaultArithmeticExp (lopd, opt, ropd)
// Interpretation:
// lopd is the left-hand operand of the Arithmetic Expression
// opt is the operator of the Arithmetic Expression
// ropd is the right-hand operand of the Arithmetic Expression
public class DefaultArithmeticExp extends AbstractExp implements ArithmeticExp {

	private Exp lopd; // left-hand operand of the Arithmetic Expression
	private Exp ropd; // right-hand operand of the Arithmetic Expression
	private String opt; // operator of the Arithmetic Expression

	/**
	 * Constructor for the DefaultArithmeticExp
	 * 
	 * @param lopd
	 * @param opt
	 * @param ropd
	 */
	public DefaultArithmeticExp(Exp lopd, String opt, Exp ropd) {
		this.lopd = lopd;
		this.ropd = ropd;
		this.opt = opt;
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
	 * @see AbstractExp#isArithmetic()
	 */
	@Override
	public boolean isArithmetic() {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#asArithmetic()
	 */
	@Override
	public ArithmeticExp asArithmetic() {
		return this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ArithmeticExp#leftOperand()
	 */
	@Override
	public Exp leftOperand() {
		return lopd;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ArithmeticExp#rightOperand()
	 */
	@Override
	public Exp rightOperand() {
		return ropd;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ArithmeticExp#operation()
	 */
	@Override
	public String operation() {
		return opt;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#value(java.util.Map)
	 */
	@Override
	public ExpVal value(Map<String, ExpVal> env) {
		// Evaluate the AirthmeticExp based on the opt
		switch (opt) {
		case "LT":
			return Asts.expVal(
					lopd.value(env).asInteger() < ropd.value(env).asInteger());
		case "EQ":
			return Asts.expVal(
					lopd.value(env).asInteger() == ropd.value(env).asInteger());
		case "GT":
			return Asts.expVal(
					lopd.value(env).asInteger() > ropd.value(env).asInteger());
		case "PLUS":
			return Asts.expVal(
					lopd.value(env).asInteger() + ropd.value(env).asInteger());
		case "MINUS":
			return Asts.expVal(
					lopd.value(env).asInteger() - ropd.value(env).asInteger());
		case "TIMES":
			return Asts.expVal(
					lopd.value(env).asInteger() * ropd.value(env).asInteger());
		default:
			// throw exception when opt is not recoganized
			throw new UnsupportedOperationException(
					"ArithmeticExp supports only 'LT', 'EQ', 'GT', 'PLUS', "
							+ "'MINUS' or 'TIMES' operation, but found " + opt);
		}
	}

}
