package ecx.managers;

import ecx.types.EntityData;
import ecx.ds.CRingBuffer_Int;
import ecx.ds.CBitArray;
import ecx.ds.CArray;

@:unreflective
@:final
@:access(ecx.Entity, ecx.types.EntityData, ecx.World)
class EntityManager {

    public var mapToData(default, null):CArray<EntityData>;
    public var aliveMask(default, null):CBitArray;
    public var activeFlags(default, null):CBitArray;
    public var removedFlags(default, null):CBitArray;
    public var changedFlags(default, null):CBitArray;

    var _pool:CRingBuffer_Int;

    public var used(default, null):Int = 0;
    public var capacity(default, null):Int;
    public var available(get, never):Int;

    public function new(world:World, capacity:Int) {
        this.capacity = capacity;

        _pool = new CRingBuffer_Int(capacity);
        aliveMask = new CBitArray(capacity);
        activeFlags = new CBitArray(capacity);
        removedFlags = new CBitArray(capacity);
        changedFlags = new CBitArray(capacity);

        var map = new CArray<EntityData>(capacity);
        for(id in 0...map.length) {
            map[id] = new EntityData(new Entity(id), world);
        }
        this.mapToData = map;
    }

    public function alloc():Entity {
        #if debug
        if(used >= capacity) throw 'Out of entities, max allowed $capacity';
        #end

        ++used;
        return new Entity(_pool.pop());
    }

    public function deleteFromWorld(world:World, list:Array<Entity>) {
        var locPool:CRingBuffer_Int = _pool;
        var locRemovedFlags = removedFlags;
        var locActiveFlags = activeFlags;
        var locAliveMask = aliveMask;
        var locMapToData = mapToData;
        while(list.length > 0) {
            var count = list.length;
            var i = 0;
            while(i < count) {
                var entity = list[i];
                world.clearComponents(entity);
                locActiveFlags.disable(entity.id);
                locAliveMask.disable(entity.id);
                locRemovedFlags.disable(entity.id);
                locPool.push(entity.id);
                ++i;
            }

            used -= count;
            #if debug
            if(used < 0) throw "No way!";
            #end

            //if(startLength != removeList.length) throw "removing while removing";
            list.splice(0, count);
        }
    }

    inline function get_available():Int {
        return capacity - used;
    }
}
