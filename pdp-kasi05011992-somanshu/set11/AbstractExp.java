import java.util.Map;

/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Abstract base class for classes that implement Exp Interface
public abstract class AbstractExp extends AbstractAst implements Exp {

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractAst#isExp()
	 */
	@Override
	public boolean isExp() {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#isConstant()
	 */
	@Override
	public boolean isConstant() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#isIdentifier()
	 */
	@Override
	public boolean isIdentifier() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#isLambda()
	 */
	@Override
	public boolean isLambda() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#isArithmetic()
	 */
	@Override
	public boolean isArithmetic() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#isCall()
	 */
	@Override
	public boolean isCall() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#isIf()
	 */
	@Override
	public boolean isIf() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#asConstant()
	 */
	@Override
	public ConstantExp asConstant() {
		throw new UnsupportedOperationException(
				"asConstant is supported only for ConstantExp, but found "
						+ this.getClass());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#asIdentifier()
	 */
	@Override
	public IdentifierExp asIdentifier() {
		throw new UnsupportedOperationException(
				"asIdentifier is supported only for IdentifierExp, but found "
						+ this.getClass());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#asLambda()
	 */
	@Override
	public LambdaExp asLambda() {
		throw new UnsupportedOperationException(
				"asLambda is supported only for LambdaExp, but found "
						+ this.getClass());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#asArithmetic()
	 */
	@Override
	public ArithmeticExp asArithmetic() {
		throw new UnsupportedOperationException(
				"asArithmetic is supported only for ArithmeticExp, but found "
						+ this.getClass());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#asCall()
	 */
	@Override
	public CallExp asCall() {
		throw new UnsupportedOperationException(
				"asCall is supported only for CallExp, but found "
						+ this.getClass());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#asIf()
	 */
	@Override
	public IfExp asIf() {
		throw new UnsupportedOperationException(
				"asIf is supported only for IfExp, but found "
						+ this.getClass());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Exp#value(java.util.Map)
	 */
	@Override
	public abstract ExpVal value(Map<String, ExpVal> env);

}
