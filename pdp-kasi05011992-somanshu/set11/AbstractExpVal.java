/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Abstract base class for classes that implement Exp Interface
public abstract class AbstractExpVal implements ExpVal {

	/*
	 * (non-Javadoc)
	 * 
	 * @see ExpVal#isBoolean()
	 */
	@Override
	public boolean isBoolean() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ExpVal#isInteger()
	 */
	@Override
	public boolean isInteger() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ExpVal#isFunction()
	 */
	@Override
	public boolean isFunction() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ExpVal#asBoolean()
	 */
	@Override
	public boolean asBoolean() {
		throw new UnsupportedOperationException(
				"asBoolean is supported only for BoolVal, but found "
						+ this.getClass());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ExpVal#asInteger()
	 */
	@Override
	public long asInteger() {
		throw new UnsupportedOperationException(
				"asInteger is supported only for IntVal, but found "
						+ this.getClass());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ExpVal#asFunction()
	 */
	@Override
	public FunVal asFunction() {
		throw new UnsupportedOperationException(
				"asFunction is supported only for FunVal, but found "
						+ this.getClass());
	}

}
