import org.jgrapht.graph.DefaultEdge;
import java.util.Objects;

/**
 * Custom labelled edge.
 * DO NOT MODIFY THIS CLASS !
 * 
 * @author jens dietrich
 */
public class ClassDependencyEdge extends DefaultEdge {

    public static enum DependencyType {
        SUPERCLASS, INTERFACE, OUTERCLASS, FIELD_TYPE, METHOD_RETURN_TYPE, METHOD_PARAMETER_TYPE,
        DECLARED_EXCEPTION_TYPE, INSTANTIATION, LOCAL_VARIABLE_TYPE, OTHER
    }

    private DependencyType type = null;

    public ClassDependencyEdge(DependencyType type) {
        this.type = type;
    }

    public DependencyType getType() {
        return type;
    }

    @Override
    public String toString() {
        return getType() + ":" + super.toString();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        ClassDependencyEdge that = (ClassDependencyEdge) o;
        return Objects.equals(this.getSource(), that.getSource()) &&
                Objects.equals(this.getTarget(), that.getTarget()) &&
                type == that.type;
    }

    @Override
    public int hashCode() {
        return Objects.hash(type, getSource(), getTarget());
    }
}
