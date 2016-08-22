package ecx;

#if idea

typedef Family<Rest> = Array<Entity>;

#else

/**
	Family is a set of Entities with required or optional Component types
**/

@:genericBuild(ecx.macro.FamilyRestGeneric.apply())
class Family<Rest> {}

#end
