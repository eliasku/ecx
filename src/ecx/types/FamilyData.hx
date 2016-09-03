package ecx.types;

import ecx.ds.CArray;
import ecx.ds.CBitArray;

@:final
@:keep
@:unreflective
@:access(ecx.System)
class FamilyData {

    public var entities(default, null):EntityVector;
    public var changed(default, null):Bool = false;
    public var total(default, null):Int = 0;

    var _containedMask:CBitArray;
    var _requiredComponents:ComponentTable;
    var _system:System;

    function new(system:System) {
        var capacity = system.world.capacity;
        entities = new EntityVector();
        _containedMask = new CBitArray(capacity);
        _system = system;
    }

    inline function require(requiredComponentTypes:Array<ComponentType>):FamilyData {
        _requiredComponents = new CArray(requiredComponentTypes != null ? requiredComponentTypes.length : 0);
        for(i in 0..._requiredComponents.length) {
            _requiredComponents[i] = _system.world.components[requiredComponentTypes[i].id];
        }
        return this;
    }

    @:nonVirtual @:unreflective
    function check(entity:Entity) {
        var rc = _requiredComponents;
        for(i in 0...rc.length) {
            if(!rc[i].has(entity)) {
                return false;
            }
        }
        return true;
    }

    @:nonVirtual @:unreflective
    inline function __invalidate() {
        entities.ensure(total);
        entities.restoreOrder(_containedMask);
        changed = false;
    }

    // TODO: check array of entities

    @:nonVirtual @:unreflective
    function __enableEntity(entity:Entity) {
        #if ecx_debug
        if(_mutable == false) throw "IMMUTABLE";
        #end
        if(!_containedMask.get(entity.id) && check(entity)) {
            #if ecx_debug
            //if(entities.__debugHas(entity)) throw "Family flags assets: id duplicated";
            #end

            _containedMask.enable(entity.id);
            _system.onEntityAdded(entity, this);
            changed = true;
            ++total;

            #if ecx_debug
            if(!_containedMask.get(entity.id)) throw "Family flags assets: can't enable";
            //if(!entities.__debugHas(entity)) throw 'ASSERT: Entity should be added to Family';
            #end
        }
    }

    @:nonVirtual @:unreflective
    function __disableEntity(entity:Entity) {
        #if ecx_debug
        if(_mutable == false) throw "IMMUTABLE";
        #end
        if(_containedMask.get(entity.id)) {
            #if ecx_debug
            //if(!entities.__debugHas(entity)) throw "Family flags assets: id not found";
            #end

            _containedMask.disable(entity.id);
            _system.onEntityRemoved(entity, this);
            changed = true;
            --total;

            #if ecx_debug
            //if(entities.__debugHas(entity)) throw "Family flags assets: id duplicated";
            if(_containedMask.get(entity.id)) throw "Family flags assets: can't disable";
            #end
        }
    }

#if ecx_debug
    var _debugEntitiesCopy:Array<Entity>;
    var _mutable:Bool = false;

    public function debugLock() {
        if(_mutable == true) throw 'imm1';
        _mutable = true;
        if(_debugEntitiesCopy == null) return;
        if(_debugEntitiesCopy.length != entities.length) throw 'Family assert: entity list access violation';
        for(i in 0..._debugEntitiesCopy.length) {
            if(_debugEntitiesCopy[i] != entities.get(i)) throw 'Family assert: entity list access violation (bad element at $i';
        }

    }

    public function debugUnlock() {
        if(_mutable == false) throw 'imm2';
        _mutable = false;
        // create immutable copy for checking
        _debugEntitiesCopy = [];
        for(e in entities) {
            _debugEntitiesCopy.push(e);
        }
    }
    #end
}