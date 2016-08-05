package ecx.managers;

import ecx.ds.CRingBuffer_Int;
import ecx.ds.CBitArray;
import ecx.ds.CArray;

@:unreflective
@:final
@:access(ecx.Entity, ecx.World)
class EntityManager {

    public var entities(default, null):CArray<Entity>;
    public var worlds(default, null):CArray<World>;
    public var removeFlags(default, null):CBitArray;
    public var updateFlags(default, null):CBitArray;

    var _pool:CRingBuffer_Int;

    public var used(default, null):Int = 0;
    public var capacity(default, null):Int;
    public var available(get, never):Int;

    public function new(engine:Engine, capacity:Int) {
        this.capacity = capacity;

        _pool = new CRingBuffer_Int(capacity);
        removeFlags = new CBitArray(capacity);
        updateFlags = new CBitArray(capacity);

        var map = new CArray<Entity>(capacity);
        var worlds = new CArray<World>(capacity);
        var e:Entity;
        for(i in 0...map.length) {
            e = new Entity();
            e.id = i;
            e.engine = engine;
            map[i] = e;
        }
        this.entities = map;
        this.worlds = worlds;
    }

    public function alloc():Int {
        #if debug
        if(used >= capacity) throw 'Out of entities, max allowed $capacity';
        #end

        var eid:Int = _pool.pop();
        ++used;

        return eid;
    }

    public function freePrefab(id:Int) {
        #if debug
        if(id < 0 || id >= capacity) throw "Bad entity id";
        if(worlds[id] != null) throw "Entity is not a prefab";
        #end
        _pool.push(id);
        --used;
    }

    public function freeFromWorld(world:World, list:Array<Int>, container:Array<Int>) {
        var locPool:CRingBuffer_Int = _pool;
        var locRemoveFlags = removeFlags;
        var locWorlds:CArray<World> = worlds;
        var locMap = entities;
        var eid:Int;
        var removedCount:Int = 0;
        while(list.length > 0) {
            var count = list.length;
            var i = 0;
            while(i < count) {
                var eid = list[i];
                var entity:Entity = locMap[eid];
                #if debug
                if(world != locWorlds[eid]) throw "Bad world on freeFromWorld";
                #end
                entity._clear();
                world._internal_entityChanged(eid);
                locWorlds[eid] = null;
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
