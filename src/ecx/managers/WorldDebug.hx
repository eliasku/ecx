package ecx.managers;

#if ecx_debug

class WorldDebug {

	@:access(ecx.World)
	public static function guardEntity(world:World, entity:Entity) {
		if(entity.isNull()) throw "Invalid entity";
		if(world._mapToData[entity.id] == null) throw "Null entity";
		if(world._aliveMask.isFalse(entity.id)) throw "Dead entity";
	}

	@:access(ecx.World)
	public static function guardFamilies(world:World) {
		for(i in 0...world._families.length) {
			var family = world._families.get(i);
			for(entity in family.entities) {
				if(entity.isNull()) throw 'FAMILY GUARD: Invalid entity id: ${entity.id}';
				if(world._aliveMask.isFalse(entity.id)) throw 'FAMILY GUARD: ${entity.id} is dead, but in family ${family.entities.length}}';
			}
		}
	}

	@:access(ecx.World)
	public static function lockFamilies(world:World) {
		for(i in 0...world._families.length) {
			world._families.get(i).debugLock();
		}
	}

	@:access(ecx.World)
	public static function unlockFamilies(world:World) {
		for(i in 0...world._families.length) {
			world._families.get(i).debugUnlock();
		}
	}
}

#end