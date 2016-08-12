package ecx;

#if display

typedef Family<T:Component> = Array<Entity>;

#else

@:genericBuild(ecx.macro.FamilyRestGeneric.apply())
class Family<Rest> {}

#end
