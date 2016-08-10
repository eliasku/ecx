package ecx.types;

import ecx.ds.CArray;
import ecx.ds.CBitArray;

@:final
@:keep
@:unreflective
@:access(ecx.System, ecx.Entity)
class Family {

    public var entities(default, null):Array<Int> = [];

    var _activeBits:CBitArray;
    var _requiredComponents:CArray<CArray<Component>>;
    var _system:System;

    function new(system:System) {
        var capacity = system.engine.entityManager.capacity;
        _activeBits = new CBitArray(capacity);
        _system = system;
    }

    inline function require(requiredComponentTypes:Array<ComponentType>):Family {
        _requiredComponents = new CArray(requiredComponentTypes != null ? requiredComponentTypes.length : 0);
        for(i in 0..._requiredComponents.length) {
            _requiredComponents[i] = _system.engine.components[requiredComponentTypes[i].id];
        }
        return this;
    }

    @:nonVirtual @:unreflective
    function check(entity:Int) {
        var rc = _requiredComponents;
        for(i in 0...rc.length) {
            if(rc[i][entity] == null) {
                return false;
            }
        }
        return true;
    }

    // TODO: check array of entities
    @:nonVirtual @:unreflective
    function _internal_entityChanged(entityId:Int, worldMatch:Bool) {
        var selected = check(entityId);
        var fits = worldMatch && selected;
        var isActive = _activeBits.get(entityId);
        if(fits && !isActive) {
            #if debug
            if(entities.indexOf(entityId) >= 0) throw "Family flags assets: id duplicated";
            #end

            _activeBits.enable(entityId);
            entities.push(entityId);
            _system.onEntityAdded(entityId, this);

            #if debug
            if(!_activeBits.get(entityId)) throw "Family flags assets: can't enable";
            #end
        }
        else if(!fits && isActive) {
            #if debug
            if(entities.indexOf(entityId) < 0) throw "Family flags assets: id not found";
            #end

            _activeBits.disable(entityId);
            entities.remove(entityId);
            _system.onEntityRemoved(entityId, this);

            #if debug
            if(entities.indexOf(entityId) >= 0) throw "Family flags assets: id duplicated";
            if(_activeBits.get(entityId)) throw "Family flags assets: can't disable";
            #end
        }

        #if debug
        if(worldMatch == false && entities.indexOf(entityId) >= 0) {
            throw 'ASSERT: Family world not matched, but entity hasn`t been deleted (fits: $fits, active: $isActive)';
        }
        #end
    }

#if debug
    var _debugEntitiesCopy:Array<Int>;

    public function debugLock() {
        if(_debugEntitiesCopy == null) return;
        if(_debugEntitiesCopy.length != entities.length) throw 'Family assert: entity list access violation';
        for(i in 0..._debugEntitiesCopy.length) {
            if(_debugEntitiesCopy[i] != entities[i]) throw 'Family assert: entity list access violation (bad element at $i';
        }

    }

    public function debugUnlock() {
        // create immutable copy for checking
        _debugEntitiesCopy = [];
        for(e in entities) {
            _debugEntitiesCopy.push(e);
        }
    }
    #end
}