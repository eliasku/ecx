package ecx.managers;

@:unreflective
@:final
@:access(ecx.Entity, ecx.World)
class EntityManager {

    var _map:Array<Entity> = [];
    var _database:Engine;
    var _nextEntityId:Int = 1;
    var _pool:FastArray<Entity>;
    var _poolHead:Int = 0;
    var _poolCap:Int = 0;

#if debug
    public var entitiesAllocated:Int = 0;
    public var entitiesPoolUsed(get, never):Int;
    public var entitiesPoolFree(get, never):Int;
    public var entitiesPoolCapacity(get, never):Int;

    inline function get_entitiesPoolUsed():Int {
        return _poolHead;
    }

    inline function get_entitiesPoolFree():Int {
        return _poolCap - _poolHead;
    }

    inline function get_entitiesPoolCapacity():Int {
        return _poolCap;
    }
#end

    public function new(database:Engine, initial:Int) {
        _database = database;
        _poolCap = initial;
        var pool = new FastArray<Entity>(initial);
        var flags = database.flags;
        var entities = database.entities;
        var e:Entity;
        var id:Int;
        for(i in 0...initial) {
            id = _nextEntityId++;
            e = new Entity();
            e.id = id;
            e.database = database;
            flags[id] = 0;
            entities[id] = e;
            pool[i] = e;
            #if debug
            ++entitiesAllocated;
            #end
        }
        _pool = pool;
    }

    public function create():Entity {
        var e:Entity = null;
        var head:Int = _poolHead;
        if(head < _poolCap) {
            e = _pool[head];
            ++_poolHead;
            _database.flags[e.id] = 0;
        }
        else {
            var id = _nextEntityId++;
            e = new Entity();
            e.database = _database;
            e.id = id;
            _database.flags[id] = 0;
            _database.entities[id] = e;
            #if debug
            ++entitiesAllocated;
            #end
        }
        return e;
    }

    public function freeFromWorld(world:World, list:Array<Entity>, container:Array<Entity>) {
        while(list.length > 0) {
            var entities:Array<Entity> = container;
            var head:Int = _poolHead;
            var pool:FastArray<Entity> = _pool;
            var flags:Array<Int> = _database.flags;
//			var count = list.length;
//			var i = 0;
            var count = list.length;
            var i = count - 1;
            while(i >= 0) {
//			while(i < count) {
                var e = list[i];
                #if debug
                if(world != e.world) throw "Bad world on freeFromWorld";
                #end
                e._clear();
//				if(_database.worlds[e.id] != null) {
                world._internal_entityChanged(e.id);
                _database.worlds[e.id] = null;
//				}
                flags[e.id] &= ~0x2;

                entities.splice(entities.lastIndexOf(e), 1);
//				entities.remove(e);
                if(head > 0) {
                    --head;
                    pool[head] = e;
                }
                else {
                    pool.push(e);
                }
                --i;
//				++i;
            }

            if(head == 0) {
                _poolCap = pool.length;
            }
            _poolHead = head;

            //if(startLength != removeList.length) throw "removing while removing";
            list.splice(0, count);
        }
    }
}
