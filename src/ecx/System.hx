package ecx;

import ecx.types.EntityMultiSet;
import ecx.types.FamilyData;
import ecx.types.SystemFlags;
import ecx.types.SystemSpec;
import ecx.types.SystemType;
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
@:autoBuild(ecx.macro.TypeBuilder.build(1))
#end
@:base
@:access(ecx.FamilyData)
class System {

	/**
		World context
	**/
	@:unreflective
	public var world(default, null):World;

	@:unreflective
	var _flags:SystemFlags = new SystemFlags();

	@:unreflective
	var _families:Array<FamilyData>;

	//@:unreflective
	function initialize() {}

	@:unreflective
	function update() {}

	//@:unreflective
	function onEntityAdded(entity:Entity, family:FamilyData) {}

	//@:unreflective
	function onEntityRemoved(entity:Entity, family:FamilyData) {}

	function _inject() {}

	//@:unreflective
	function __getType():SystemType {
		return SystemType.INVALID;
	}

	//@:unreflective
	function __getSpec():SystemSpec {
		return SystemSpec.INVALID;
	}

	@:nonVirtual @:unreflective
	function _internal_entityChanged(entity:Entity, enabled:Bool) {
		for(family in _families) {
			@:privateAccess family._internal_entityChanged(entity, enabled);
		}
	}

	macro function _family(self:ExprOf<System>, requiredComponents:Array<ExprOf<Class<Component>>>):ExprOf<EntityMultiSet> {
		var componentTypeList = requiredComponents.componentTypeList();
		return macro $self._addFamily(@:privateAccess new ecx.types.FamilyData($self).require($componentTypeList));
	}

	@:nonVirtual @:unreflective
	function _addFamily(family:FamilyData):EntityMultiSet {
		if(_families == null) {
			_families = [];
			_flags = _flags.add(SystemFlags.PROCESSOR);
		}
		_families.push(family);
		return family.entities;
	}

	@:nonVirtual @:unreflective @:extern
	inline function _isIdle():Bool {
		return _flags.has(SystemFlags.IDLE);
	}

	@:nonVirtual @:unreflective @:extern
	inline function _isProcessor():Bool {
		return _flags.has(SystemFlags.PROCESSOR);
	}

	inline function toString():String {
		return 'System(Type: #${__getType().id}, Spec: #${__getSpec().id})';
	}
}