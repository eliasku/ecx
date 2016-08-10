package ecx;

import ecx.types.Family;
import ecx.types.SystemFlags;
import ecx.types.SystemSpec;
import ecx.types.SystemType;
import ecx.macro.ManagerMacro;
import haxe.macro.Expr;

/**
 Initialization:
 - all constructed via configuration
 - all injected
 - all initialized
 - updates
**/

#if !macro
@:autoBuild(ecx.macro.WorldTypeBuilder.build(1))
#end
@:base
@:access(ecx.Family)
class System {

	@:unreflective
	public var world(default, null):World;

	@:unreflective
	public var engine(default, null):Engine;

	@:unreflective
	var _flags:SystemFlags = new SystemFlags();

	@:unreflective
	var _families:Array<Family>;

	function initialize() {}
	function update() {}

	function onEntityAdded(entityId:Int, family:Family) {}
	function onEntityRemoved(entityId:Int, family:Family) {}

	function _inject() {}

	function __getType():SystemType {
		return SystemType.INVALID;
	}

	function __getSpec():SystemSpec {
		return SystemSpec.INVALID;
	}

	@:nonVirtual @:unreflective
	function _internal_entityChanged(entityId:Int, worldMatched:Bool) {
		for(family in _families) {
			@:privateAccess family._internal_entityChanged(entityId, worldMatched);
		}
	}

	macro function _family(self:ExprOf<System>, requiredComponents:Array<ExprOf<Class<Component>>>):ExprOf<Array<Entity>> {
		var componentTypeList = ManagerMacro.componentTypeList(requiredComponents);
		return macro $self._addFamily(@:privateAccess new ecx.types.Family($self).require($componentTypeList));
	}

	@:nonVirtual @:unreflective
	function _addFamily(family:Family):Array<Int> {
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