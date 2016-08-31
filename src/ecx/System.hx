package ecx;

import ecx.types.EntityVector;
import ecx.types.FamilyData;
import ecx.types.SystemFlags;
import haxe.macro.Expr;

using ecx.macro.ClassMacroTools;

/**
	Service-based system type. System unify world-scope Context or Behaviour

	Initialization steps:
	- all systems are constructed via world-configuration
	- all systems are wired with each other
	- all systems are initialized
	- systems are able to be updated (if not IDLE)

	@see ecx.Wire
	@see ecx.Family
**/

#if !macro
@:autoBuild(ecx.macro.SystemBuilder.build())
#end
@:base
@:access(ecx.FamilyData)
class System extends Service {

	@:unreflective
	var _flags:SystemFlags = new SystemFlags();

	@:unreflective
	var _families:Array<FamilyData>;

	@:unreflective
	function update() {}

	//@:unreflective
	function onEntityAdded(entity:Entity, family:FamilyData) {}

	//@:unreflective
	function onEntityRemoved(entity:Entity, family:FamilyData) {}

	macro function _family(self:ExprOf<System>, requiredComponents:Array<ExprOf<Class<Component<Dynamic>>>>):ExprOf<EntityVector> {
		var componentTypes = requiredComponents.componentTypeList();
		return macro $self._addFamily(@:privateAccess new ecx.types.FamilyData($self).require($componentTypes));
	}

	function __configure() {}

	@:nonVirtual @:unreflective
	function _addFamily(family:FamilyData):EntityVector {
		if(_families == null) {
			_families = [];
		}
		_families.push(family);
		return family.entities;
	}

	@:nonVirtual @:unreflective @:extern
	inline function _isIdle():Bool {
		return _flags.has(SystemFlags.IDLE);
	}

	inline function toString():String {
		return 'System(Type: #${__serviceType().id}, Spec: #${__serviceSpec().id})';
	}
}