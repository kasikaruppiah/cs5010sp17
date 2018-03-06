import java.util.Objects;

/**
 * Created by pdp-kasi05011992-somanshu on 3/24/17.
 *
 // Constructor template for DefaultRacketList:
 //     new DefaultRacketList ()
 //     new DefaultRacketList (first, rest)
 // Interpretation:
 //     first is a object of type E
 //     rest is a RacketList of type E
 */
public class DefaultRacketList<E> implements RacketList<E> {
    private E first;
    private RacketList<E> rest;

    // the java constructor

    /**
     * GIVEN:
     *      None
     * RETURNS:
     *      a RacketList with first and rest set to null
     */
    public DefaultRacketList() {
        this.first = null;
        this.rest = null;
    }

    // the java constructor

    /**
     * GIVEN:
     * @param first first element of the new RacketList
     * @param rest  RacketList
     * RETURNS:
     * a RacketList of with input details
     */
    private DefaultRacketList(E first, RacketList<E> rest) {
        this.first = first;
        this.rest = rest;
    }

    @Override
    public boolean isEmpty() {
        return (first == null) && (rest == null);
    }

    @Override
    public E first() {
        return first;
    }

    @Override
    public RacketList<E> rest() {
        return rest;
    }

    @Override
    public RacketList<E> cons(E x) {
        return new DefaultRacketList(x, this);
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj == null || !(obj instanceof DefaultRacketList)) {
            return false;
        }
        DefaultRacketList<E> racketList = (DefaultRacketList<E>) obj;
        return RacketLists.isEqual(this, racketList);
    }

    @Override
    public int hashCode() {
        return Objects.hash(first, rest);
    }

    @Override
    public String toString() {
        return RacketLists.toString(this);
    }
}