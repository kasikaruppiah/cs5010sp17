import java.util.Map;

/**
 * 
 */

/**
 * @author kasi
 *
 */
public class DefaultFunVal extends AbstractExpVal implements FunVal {

	private LambdaExp code;
	private Map<String, ExpVal> environment;

	/**
	 * Constructor for DefaultFunVal
	 * 
	 * @param code
	 * @param environment
	 */
	public DefaultFunVal(LambdaExp code, Map<String, ExpVal> environment) {
		this.code = code;
		this.environment = environment;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ExpVal#isFunction()
	 */
	@Override
	public boolean isFunction() {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ExpVal#asFunction()
	 */
	@Override
	public FunVal asFunction() {
		return this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see FunVal#code()
	 */
	@Override
	public LambdaExp code() {
		return code;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see FunVal#environment()
	 */
	@Override
	public Map<String, ExpVal> environment() {
		return environment;
	}

}
