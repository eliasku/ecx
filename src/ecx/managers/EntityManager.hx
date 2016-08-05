package ecx.managers;

import ecx.ds.CRingPool;
import ecx.ds.CBitArray;
import ecx.ds.CArray;

@:unreflective
@:final
@:access(ecx.Entity, ecx.World)
class EntityManager {

    public var map(default, null):CArray<Entity>;
    public var worlds(default, null):CArray<World>;
    public var removeFlags(default, null):CBitArray;
    public var updateFlags(default, null):CBitArray;

    // TODO: should we reserve 0 index for invalid entity?
    //var _nextId:Int = 1;
    var _pool:CArray<Entity>;

    public var allocated(default, null):Int = 0;
    public var used(default, null):Int = 0;
    public var capacity(default, null):Int;
    public var available(get, never):Int;

   // var _idPool:CRingPool;

    inline function get_available():Int {
        return capacity - used;
    }

    public function new(engine:Engine, capacity:Int) {
        this.capacity = capacity;

        //_idPool = new CRingPool(capacity);
        var pool = new CArray(capacity);
        var map = new CArray(capacity + 1);
        var worlds = new CArray(capacity + 1);
        removeFlags = new CBitArray(capacity + 1);
        updateFlags = new CBitArray(capacity + 1);

        var e:Entity;
        var eid:Int = 1;
        //var nextId:Int = 1;
        for(i in 0...capacity) {
            //id = nextId++;
            e = new Entity();
            e.id = eid;
            e.engine = engine;
            map[eid] = e;
            pool[i] = e;
            ++eid;
        }
        allocated += capacity;
        //_nextId = uid;
        _pool = pool;
        this.map = map;
        this.worlds = worlds;
    }

    public function create():Entity {
        var head:Int = used;
        if(head >= capacity) {
            throw 'Out of entities, max allowed $capacity';
        }
        var e:Entity = _pool[head];
        ++used;

        // TODO: if it neseccary?
        removeFlags[e.id] = false;

        return e;
    }

    public function freePrefab(entity:Entity) {
        #if debug
        if(entity == null) throw "Invalid argument";
        if(entity.world != null) throw "Entity is not a prefab";
        #end
        _pool[used] = entity;
        --used;
    }

    public function freeFromWorld(world:World, list:Array<Int>, container:Array<Int>) {
        var locPool:CArray<Entity> = _pool;
        var locRemoveFlags = removeFlags;
        var locWorlds:CArray<World> = worlds;
        var locMap = map;
        var eid:Int;
        while(list.length > 0) {
            var entities:Array<Int> = container;
            var head:Int = used;
            var count = list.length;
            var i = count - 1;
            while(i >= 0) {
                var eid = list[i];
                var entity:Entity = locMap[eid];
                #if debug
                if(world != locWorlds[eid]) throw "Bad world on freeFromWorld";
                #end
                entity._clear();
                world._internal_entityChanged(eid);
                locWorlds[eid] = null;
                locRemoveFlags.disable(eid);

                entities.splice(entities.lastIndexOf(eid), 1);
                --head;
                locPool[head] = entity;
                --i;
            }

            if(head < 0) throw "No way!";

            used = head;

            //if(startLength != removeList.length) throw "removing while removing";
            list.splice(0, count);
        }
    }
}
