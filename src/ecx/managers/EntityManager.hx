package ecx.managers;

import ecx.ds.CArray;

@:unreflective
@:final
@:access(ecx.Entity, ecx.World)
class EntityManager {

    public var map(default, null):CArray<Entity>;
    public var worlds(default, null):CArray<World>;
    public var flags(default, null):CArray<Int>;

    // TODO: should we reserve 0 index for invalid entity?
    var _nextId:Int = 1;
    var _pool:CArray<Entity>;

    public var allocated(default, null):Int = 0;
    public var used(default, null):Int = 0;
    public var capacity(default, null):Int;
    public var available(get, never):Int;

    inline function get_available():Int {
        return capacity - used;
    }

    public function new(engine:Engine, capacity:Int) {
        this.capacity = capacity;

        var pool = new CArray(capacity);
        var flags = new CArray(capacity + 1);
        var map = new CArray(capacity + 1);
        var worlds = new CArray(capacity + 1);

        var e:Entity;
        var id:Int;
        var uid:Int = _nextId;
        for(i in 0...capacity) {
            id = uid++;
            e = new Entity();
            e.id = id;
            e.engine = engine;
            flags[id] = 0;
            map[id] = e;
            pool[i] = e;
        }
        allocated += capacity;
        _nextId = uid;
        _pool = pool;
        this.flags = flags;
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
        flags[e.id] = 0;
        return e;
    }

    public function freePrefab(entity:Entity) {
        //if(entity == null) throw "Invalid argument";
        if(entity.world != null) throw "Entity is not a prefab";
        _pool[used] = entity;
        --used;
    }

    public function freeFromWorld(world:World, list:Array<Entity>, container:Array<Entity>) {
        var locPool:CArray<Entity> = _pool;
        var locFlags:CArray<Int> = flags;
        var locWorlds:CArray<World> = worlds;
        while(list.length > 0) {
            var entities:Array<Entity> = container;
            var head:Int = used;
            var count = list.length;
            var i = count - 1;
            while(i >= 0) {
                var e = list[i];
                #if debug
                if(world != e.world) throw "Bad world on freeFromWorld";
                #end
                e._clear();
                world._internal_entityChanged(e.id);
                locWorlds[e.id] = null;
                locFlags[e.id] &= ~0x2;

                entities.splice(entities.lastIndexOf(e), 1);
                --head;
                locPool[head] = e;
                --i;
            }

            if(head < 0) throw "No way!";

            used = head;

            //if(startLength != removeList.length) throw "removing while removing";
            list.splice(0, count);
        }
    }
}
