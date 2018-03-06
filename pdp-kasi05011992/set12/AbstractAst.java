import java.util.List;

/**
 * @author pdp-kasi05011992-somanshu
 *
 */

// Abstract base class for classes that implement Ast Interface
public abstract class AbstractAst implements Ast {

	/*
	 * (non-Javadoc)
	 * 
	 * @see Ast#isPgm()
	 */
	@Override
	public boolean isPgm() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Ast#isDef()
	 */
	@Override
	public boolean isDef() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Ast#isExp()
	 */
	@Override
	public boolean isExp() {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Ast#asPgm()
	 */
	@Override
	public List<Def> asPgm() {
		throw new UnsupportedOperationException(
				"asPgm is supported only for Pgm, but found "
						+ this.getClass());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Ast#asDef()
	 */
	@Override
	public Def asDef() {
		throw new UnsupportedOperationException(
				"asDef is supported only for Def, but found "
						+ this.getClass());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see Ast#asExp()
	 */
	@Override
	public Exp asExp() {
		throw new UnsupportedOperationException(
				"asExp is supported only for Exp, but found "
						+ this.getClass());
	}

}
