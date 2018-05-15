package ecx;

/**
	Config for `World` instantiation.
	Extend this class to define your own `Plugins`
**/
@:unreflective
class WorldConfig {

	var _services:Array<Service> = [];
	var _priorities:Array<Int> = [];

	/**
		Create empty `WorldConfig`
	**/
	public function new() {}

	/**
		Adds `service` instance to config. It could be `Component`/`System`/`Service`.
		`priority` is optional value for `System` instances.
		Systems with the lowest priority running first.
	**/
	public function add(service:Service, priority:Int = 0):WorldConfig {
		if(service == null) throw "WorldConfig: service should be not null";
		if(_services.lastIndexOf(service) >= 0) throw "WorldConfig: service duplicated";

		_services.push(service);
		_priorities.push(priority);

		return this;
	}

	/**
		Include plugin `WorldConfig` instance.
	**/
	public function include(config:WorldConfig):WorldConfig {
		if(config == null) throw "WorldConfig: config should be not null";
		if(config == this) throw "WorldConfig: should not include self";

		var services = config._services;
		var priorities = config._priorities;
		for(i in 0...services.length) {
			add(services[i], priorities[i]);
		}

		return this;
	}
}