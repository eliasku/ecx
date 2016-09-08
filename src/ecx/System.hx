package ecx;

import ecx.types.EntityVector;
import ecx.types.FamilyData;
import ecx.types.SystemFlags;
import haxe.macro.Expr;

using ecx.macro.ClassMacroTools;

/**
	System is Service which need to update.
	System's priority will be defined in `WorldConfig`.
	Has ability to define aspects `Family<...>` for oredered entity sets

	@see ecx.Family
**/
#if !macro
@:autoBuild(ecx.macro.SystemBuilder.build())
#end
@:core
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

    macro function _family(self:ExprOf<System>, requiredComponents:Array<ExprOf<Class<IComponent>>>):ExprOf<EntityVector> {
        var componentTypes = requiredComponents.componentTypeList();
        return macro $self._addFamily(@:privateAccess new ecx.types.FamilyData(world, $self).require($componentTypes));
    }

    function __configure() {}

    @:nonVirtual @:unreflective
    function _addFamily(family:FamilyData):EntityVector {
        if (_families == null) {
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