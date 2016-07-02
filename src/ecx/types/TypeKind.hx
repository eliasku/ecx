package ecx.types;

@:enum abstract TypeKind(Int) from Int to Int {
    var COMPONENT = 0;
    var SYSTEM = 1;
}
