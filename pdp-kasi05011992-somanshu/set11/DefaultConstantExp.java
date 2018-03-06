import java.util.Map;

/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Constructor template for DefaultConstantExp:
// new DefaultConstantExp (value)
// Interpretation:
// value is the value of this constant expression
public class DefaultConstantExp extends AbstractExp implements ConstantExp {

	private ExpVal value; // the value of this constant expression

	/**
	 * Constructor of the DefaultConstantExp
	 * 
	 * @param value
	 */
	public DefaultConstantExp(ExpVal value) {
		this.value = value;
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
	 * @see AbstractExp#isConstant()
	 */
	@Override
	public boolean isConstant() {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#asConstant()
	 */
	@Override
	public ConstantExp asConstant() {
		return this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ConstantExp#value()
	 */
	@Override
	public ExpVal value() {
		return value;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#value(java.util.Map)
	 */
	@Override
	public ExpVal value(Map<String, ExpVal> env) {
		return value();
	}

}
