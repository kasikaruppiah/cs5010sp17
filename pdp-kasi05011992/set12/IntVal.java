/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Constructor template for IntVal:
// new BoolVal(integer)
// Interpretation:
// integer is the long value
public class IntVal extends AbstractExpVal {

	private long integer; // long value

	/**
	 * Constructor template for IntVal
	 */
	public IntVal(long integer) {
		this.integer = integer;
	}

	/**
	 * @return
	 */
	@Override
	public boolean isInteger() {
		return true;
	}

	/**
	 * @return
	 */
	@Override
	public long asInteger() {
		return integer;
	}

}
