package ecx.managers;

import ecx.ds.CRingBuffer_Int;
import ecx.ds.CBitArray;
import ecx.ds.CArray;

@:unreflective
@:final
@:access(ecx.EntityView, ecx.World)
class EntityManager {

    public var entities(default, null):CArray<EntityView>;
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
        activeFlags = new CBitArray(capacity);
        removedFlags = new CBitArray(capacity);
        changedFlags = new CBitArray(capacity);

        var map = new CArray<EntityView>(capacity);
        for(id in 0...map.length) {
            map[id] = new EntityView(id, world);
        }
        this.entities = map;
    }

    public function alloc():Int {
        #if debug
        if(used >= capacity) throw 'Out of entities, max allowed $capacity';
        #end

        var eid:Int = _pool.pop();
        ++used;

        return eid;
    }

    public function deleteFromWorld(world:World, list:Array<Int>, container:Array<Int>) {
        var locPool:CRingBuffer_Int = _pool;
        var locRemoveFlags = removedFlags;
        var locActiveFlags = activeFlags;
        var locMap = entities;
        var eid:Int;
        var removedCount:Int = 0;
        while(list.length > 0) {
            var count = list.length;
            var i = 0;
            while(i < count) {
                var eid = list[i];
                var entity = locMap.get(eid);
                entity._clear();
                if(locActiveFlags.get(eid)) {
                    // TODO: we 100% sure to delete it from families :)
                    world._internal_entityChanged(eid);
                    locActiveFlags.disable(eid);
                }
                locRemoveFlags.disable(eid);

                container.splice(container.lastIndexOf(eid), 1);
                locPool.push(eid);
                ++i;
            }

            used -= count;
            if(used < 0) throw "No way!";

            //if(startLength != removeList.length) throw "removing while removing";
            list.splice(0, count);
        }
    }

    inline function get_available():Int {
        return capacity - used;
    }
}
