/**
 * 
 */

/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Constructor template for BoolVal:
// new BoolVal(bool)
// Interpretation:
// bool is the boolean value
public class BoolVal extends AbstractExpVal {

	private boolean bool; // boolean value

	/**
	 * constructor for BoolVal
	 */
	public BoolVal(boolean bool) {
		this.bool = bool;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExpVal#isBoolean()
	 */
	@Override
	public boolean isBoolean() {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExpVal#asBoolean()
	 */
	@Override
	public boolean asBoolean() {
		return bool;
	}

}
