import java.util.Map;

/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Constructor template for DefaultIdentifierExp:
// new DefaultIdentifierExp (name)
// Interpretation:
// name is the name of this identifier
public class DefaultIdentifierExp extends AbstractExp implements IdentifierExp {

	private String name; // the name of this identifier

	/**
	 * Constructor for the DefaultIdentifierExp
	 * 
	 * @param name
	 */
	public DefaultIdentifierExp(String name) {
		this.name = name;
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
	 * @see AbstractExp#isIdentifier()
	 */
	@Override
	public boolean isIdentifier() {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#asIdentifier()
	 */
	@Override
	public IdentifierExp asIdentifier() {
		return this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see IdentifierExp#name()
	 */
	@Override
	public String name() {
		return name;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see AbstractExp#value(java.util.Map)
	 */
	@Override
	public ExpVal value(Map<String, ExpVal> env) {
		// get the value from environment
		if (env.containsKey(name)) {
			return env.get(name);
		} else {
			throw new IllegalArgumentException(
					name + " not found in the environment");
		}
	}

}
