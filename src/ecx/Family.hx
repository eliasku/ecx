package ecx;

#if idea

typedef Family<Rest> = Array<Entity>;

#else

@:genericBuild(ecx.macro.FamilyRestGeneric.apply())
class Family<Rest> {}

#end
