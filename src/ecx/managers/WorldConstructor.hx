package ecx.managers;

import ecx.ds.CBitArray;
import ecx.types.EntityData;
import ecx.ds.CInt32RingBuffer;
import ecx.ds.CArray;
import ecx.types.FamilyData;

@:dce @:final @:unreflective
@:access(ecx.World, ecx.System, ecx.Engine, ecx.Entity)
@:access(ecx.WorldConfig, ecx.types.EntityData)
@:allow(ecx.World)
class WorldConstructor {

	static function nextPowerOfTwo(value:Int):Int {
		if (value == 0) {
			return 1;
		}
		--value;
		value |= value >> 1;
		value |= value >> 2;
		value |= value >> 4;
		value |= value >> 8;
		value |= value >> 16;
		return value + 1;
	}

	static function construct(world:World, capacity:Int, config:WorldConfig) {
		world.capacity = nextPowerOfTwo(capacity);
		createComponentsData(world);
		createEntityManager(world);
		createSystemLookup(world, config);
		createSystemsOrder(world, config);
		routeSystems(world);
		createFamilyList(world);
		initializeSystems(world);
		deleteConfigurators(world);
	}

	static function createComponentsData(world:World) {
		var capacity = world.capacity;
		var typesCount = world.engine.getComponentTypesCount();

//		#if flash
//		var components:CArray<Dynamic> = new CArray(typesCount);
//		for(i in 0...typesCount) {
//			var types = world.engine._types;
////			var cls = types.compalcl[i];
////			Type.getClassFields(cls);
////			if(cls == null) throw "No class for " + i;
////			var method = types.compal[i];
////			if(method != null) {
////				var vec = Reflect.callMethod(cls, method, [capacity]);
////				components[i] = vec;
////			}
////			else {
////
////				throw "No method for " + i + " " + Type.getClassFields(cls).join(",");
////			}
//			components[i] = @:privateAccess TypeManager._newvec[i](capacity);
//		}
//		#else
		var components:CArray<CArray<Component>> = new CArray(typesCount);
		for(i in 0...typesCount) {
			components[i] = new CArray(capacity);
		}
//		#end

		world.components = components;
	}

	static function createEntityManager(world:World) {
		var capacity = world.capacity;
		var pool = new CInt32RingBuffer(capacity);
		for(i in 0...capacity) {
			pool.set(i, i);
		}

		world._pool = pool;
		world._aliveMask = new CBitArray(capacity);
		world._activeFlags = new CBitArray(capacity);
		world._removedFlags = new CBitArray(capacity);
		world._changedFlags = new CBitArray(capacity);

		var map = new CArray<EntityData>(capacity);
		for(id in 0...capacity) {
			map[id] = new EntityData(new Entity(id), world);
		}
		world._mapToData = map;
	}

	static function createSystemLookup(world:World, config:WorldConfig) {
		var lookup = new Array<System>();
		for(system in config._systems) {
			lookup[system.__getType().id] = system;
		}
		world._lookup = CArray.fromArray(lookup);
	}

	static function createSystemsOrder(world:World, config:WorldConfig) {
		var systems = config._systems;
		var priorities = config._priorities;

		var sortIndices:Array<Int> = [];
		for(i in 0...systems.length) {
			sortIndices.push(i);
		}

		sortIndices.sort(function (x, y) {
			return priorities[x] - priorities[y];
		});

		world._orderedSystems = new CArray(systems.length);
		for(i in 0...systems.length) {
			world._orderedSystems[i] = systems[sortIndices[i]];
		}
	}

	static function routeSystems(world:World) {
		// var systems = world._orderedSystems;
		var processors = [];
		var active = [];

		for(system in world._orderedSystems) {
			system.world = world;
			system._inject();
			if(system._isProcessor()) {
				processors.push(system);
			}
			if(!system._isIdle()) {
				active.push(system);
			}
		}
		world._systems = CArray.fromArray(active);
		world._processors = CArray.fromArray(processors);
	}

	static function createFamilyList(world:World) {
		var families:Array<FamilyData> = [];

		for(processor in world._processors) {
			for(family in processor._families) {
				families.push(family);
			}
		}

		world._families = CArray.fromArray(families);
	}

	static function initializeSystems(world:World) {
		for(system in world._orderedSystems) {
			system.initialize();
		}
	}

	static function deleteConfigurators(world:World) {
		// TODO: somehow
	}

	// TODO: mem usage calculator
	public static function calculateMemoryUsage(capacity:Int, components:Int, families:Int) {
		var min = 0;
		var ptrSize = 4;
		var idSize = 4;
		var bitArraySize = 4 * Math.ceil(capacity / 32);

		// 4 flag bit arrays
		min += (4 + families) * bitArraySize;

		// component storage
		min += ptrSize * components;

		// per component
		min += (capacity * ptrSize) * components;

		// entity ring buffer
		min += capacity * idSize;

		// entity data map
		min += (ptrSize + ptrSize + idSize) * capacity;

		return min;
	}
}
