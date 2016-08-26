package ecx.types;

@:final
@:unreflective
class EntityData {

    public var entity(default, null):Entity;
    public var world(default, null):World;

    inline function new(entity:Entity, world:World) {
        this.entity = entity;
        this.world = world;
    }
}
