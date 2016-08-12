package ecx.types;

import ecx.ds.CArray;
import ecx.ds.CBitArray;

@:final
@:keep
@:unreflective
@:access(ecx.System, ecx.EntityView)
class FamilyData {

    public var entities(default, null):Array<Entity> = [];

    var _containedBits:CBitArray;
    var _requiredComponents:CArray<CArray<Component>>;
    var _system:System;

    function new(system:System) {
        var capacity = system.world.capacity;
        _containedBits = new CBitArray(capacity);
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
            if(rc[i][entity.id] == null) {
                return false;
            }
        }
        return true;
    }

    // TODO: check array of entities
    @:nonVirtual @:unreflective
    function _internal_entityChanged(entity:Entity, active:Bool) {
        var matched = active && check(entity);
        var contained = _containedBits.get(entity.id);
        if(matched && !contained) {
            #if debug
            if(entities.indexOf(entity) >= 0) throw "Family flags assets: id duplicated";
            #end

            _containedBits.enable(entity.id);
            entities.push(entity);
            _system.onEntityAdded(entity, this);

            #if debug
            if(!_containedBits.get(entity.id)) throw "Family flags assets: can't enable";
            #end
        }
        else if(!matched && contained) {
            #if debug
            if(entities.indexOf(entity) < 0) throw "Family flags assets: id not found";
            #end

            _containedBits.disable(entity.id);
            entities.remove(entity);
            _system.onEntityRemoved(entity, this);

            #if debug
            if(entities.indexOf(entity) >= 0) throw "Family flags assets: id duplicated";
            if(_containedBits.get(entity.id)) throw "Family flags assets: can't disable";
            #end
        }

        #if debug
        if(active == false && entities.indexOf(entity) >= 0) {
            throw 'ASSERT: Family world not matched, but entity hasn`t been deleted (matched: $matched, contained: $contained)';
        }
        #end
    }

#if debug
    var _debugEntitiesCopy:Array<Entity>;

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