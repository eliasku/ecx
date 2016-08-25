package ecx.managers;

import ecx.types.ComponentTable;
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
		createComponentsData(config, world);
		createEntityManager(world);
		createServicesLookup(world, config);
		createServicesOrder(world, config);
		routeServices(world);
		createFamilyList(world);
		initializeServices(world);
		deleteConfigurators(world);
	}

	@:access(ecx.Component)
	static function createComponentsData(config:WorldConfig, world:World) {
		var components:Array<Component> = [];
		var maxType = 0;
		for(service in config._services) {
			if(Std.is(service, Component)) {
				var component:Component = cast service;
				components.push(component);
				var typeId = @:privateAccess component.__componentType().id;
				if(typeId > maxType) {
					maxType = typeId;
				}
			}
		}

		var capacity = world.capacity;
		var typesCount = maxType + 1;

		var table = new ComponentTable(typesCount);
		for(component in components) {
			table[component.__componentType().id] = component;
		}

		world.components = table;
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

	@:access(ecx.Service)
	static function createServicesLookup(world:World, config:WorldConfig) {
		var services = new Array<Service>();
		for(system in config._services) {
			services[system.__serviceType().id] = system;
		}
		world._services = CArray.fromArray(services);
	}

	static function createServicesOrder(world:World, config:WorldConfig) {
		var services = config._services;
		var priorities = config._priorities;

		var sortIndices:Array<Int> = [];
		for(i in 0...services.length) {
			sortIndices.push(i);
		}

		sortIndices.sort(function (x, y) {
			return priorities[x] - priorities[y];
		});

		world._orderedServices = new CArray(services.length);
		for(i in 0...services.length) {
			world._orderedServices[i] = services[sortIndices[i]];
		}
	}

	@:access(ecx.Service)
	static function routeServices(world:World) {
		var processors = [];
		var active = [];

		for(service in world._orderedServices) {
			service.world = world;
			service.__allocate();
			service.__inject();
			var system:System = Std.instance(service, System);
			if(system != null) {
				if(system._families != null && system._families.length > 0) {
					processors.push(system);
				}
				if(!system._isIdle()) {
					active.push(system);
				}
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

	@:access(ecx.Service)
	static function initializeServices(world:World) {
		for(service in world._orderedServices) {
			service.initialize();
		}
	}

	static function deleteConfigurators(world:World) {
		// TODO: somehow
	}

	// TODO: mem usage calculator
	public static function calculateMemoryUsage(capacity:Int, components:Int, families:Int) {
		var min = 0;
		return min;
	}
}
