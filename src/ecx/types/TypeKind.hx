package ecx.types;

@:dce @:final @:unreflective
@:enum abstract TypeKind(Int) from Int to Int {

    public static inline var TOTAL:Int = 2;

    var COMPONENT = 0;
    var SYSTEM = 1;

    public function toString() {
        return this == COMPONENT ? "Component" : "System";
    }
}
