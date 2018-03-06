/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Constructor template for DefaultDef:
// new DefaultDef(lhs, rhs)
// Interpretation:
// lhs is the left hand side of this definition, an identifier represented as a
// String
// rhs the right hand side of this definition, a ConstantExp or a LambdaExp
public class DefaultDef extends AbstractAst implements Def {

	private String lhs; // the left hand side of this definition,
	private Exp rhs; // the right hand side of this definition

	/**
	 * Constructor for DefaultDef
	 * 
	 * @param lhs
	 * @param rhs
	 */
	public DefaultDef(String lhs, Exp rhs) {
		this.lhs = lhs;
		this.rhs = rhs;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Ast#isDef()
	 */
	@Override
	public boolean isDef() {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Ast#asDef()
	 */
	@Override
	public Def asDef() {
		return this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Def#lhs()
	 */
	@Override
	public String lhs() {
		return lhs;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Def#rhs()
	 */
	@Override
	public Exp rhs() {
		return rhs;
	}

}
