package ecx.managers;

import ecx.ds.CArray;

@:unreflective
@:final
@:access(ecx.Entity, ecx.World)
class EntityManager {

    var _engine:Engine;
    var _nextEntityId:Int = 1;
    var _pool:CArray<Entity>;
    var _poolHead:Int = 0;

    public var allocated(default, null):Int = 0;
    public var capacity(default, null):Int;
    public var used(get, never):Int;
    public var available(get, never):Int;

    inline function get_used():Int {
        return _poolHead;
    }

    inline function get_available():Int {
        return capacity - _poolHead;
    }

    public function new(database:Engine, capacity:Int) {
        this.capacity = capacity;
        _engine = database;
        var pool = new CArray<Entity>(capacity);
        var flags = database.flags;
        var entities = database.entities;
        var e:Entity;
        var id:Int;
        var uid:Int = _nextEntityId;
        for(i in 0...capacity) {
            id = uid++;
            e = new Entity();
            e.id = id;
            e.database = database;
            flags[id] = 0;
            entities[id] = e;
            pool[i] = e;
        }
        allocated += capacity;
        _nextEntityId = uid;
        _pool = pool;
    }

    public function create():Entity {
        var head:Int = _poolHead;
        if(head >= capacity) {
            throw "Out of entities";
        }
        var e:Entity = _pool[head];
        ++_poolHead;
        _engine.flags[e.id] = 0;
        return e;
    }

    public function freeFromWorld(world:World, list:Array<Entity>, container:Array<Entity>) {
        while(list.length > 0) {
            var entities:Array<Entity> = container;
            var head:Int = _poolHead;
            var pool:CArray<Entity> = _pool;
            var flags:CArray<Int> = _engine.flags;
            var count = list.length;
            var i = count - 1;
            while(i >= 0) {
                var e = list[i];
                #if debug
                if(world != e.world) throw "Bad world on freeFromWorld";
                #end
                e._clear();
                world._internal_entityChanged(e.id);
                _engine.worlds[e.id] = null;
                flags[e.id] &= ~0x2;

                entities.splice(entities.lastIndexOf(e), 1);
                --head;
                pool[head] = e;
                --i;
            }

            if(head < 0) throw "No way!";

            _poolHead = head;

            //if(startLength != removeList.length) throw "removing while removing";
            list.splice(0, count);
        }
    }
}
