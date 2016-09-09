package ecx;

/**
	Config for `World` instantiation.
	Extend this class to create your own "Plugins"
**/
@:unreflective
class WorldConfig {

	var _services:Array<Service> = [];
	var _priorities:Array<Int> = [];

	/**
		Create `WorldConfig`.
		Optional `dependencies` could require array of "Plugins" to include
	**/
	public function new(dependencies:Array<WorldConfig> = null) {
		if(dependencies != null) {
			for(dependency in dependencies) {
				include(dependency);
			}
		}
	}

	/** DEPRECATED! Use `include()` instead **/
	@:deprecated("Use include() instead")
	public function require(config:WorldConfig) {
		include(config);
	}

	/**
		Adds `service` instance to config. It could be `Component`/`System`/`Service`.
		`priority` is optional value for `System` instances.
		Systems with the lowest priority running first.
	**/
	public function add(service:Service, priority:Int = 0) {
		#if ecx_debug
		if(service == null) throw "Null service";
		if(_services.indexOf(service) >= 0) throw "Service already added";
		#end

		_services.push(service);
		_priorities.push(priority);
	}

	/**
		Include plugin `WorldConfig` instance.
	**/
	public function include(config:WorldConfig) {
		#if ecx_debug
		checkAddedConfigs(config);
		_guardConfigs.push(config);
		#end

		var services = config._services;
		var priorities = config._priorities;
		var count = services.length;
		for(i in 0...count) {
			add(services[i], priorities[i]);
		}
	}

	#if ecx_debug

	var _guardConfigs:Array<WorldConfig> = [];

	function checkAddedConfigs(config:WorldConfig) {
		if(config == null) throw "null config";
		if(config == this) throw "can't add self";
		for(c in _guardConfigs) {
			c.checkAddedConfigs(config);
		}
	}

	#end

//	/**
//		Create instance of service
//
//		Usage: `config.require(MotionSystem, priority);`
//	**/
//	macro public function requireAuto<T:Service>(self:ExprOf<WorldConfig>, serviceClass:ExprOf<Class<T>>, ?priority:Expr):Expr {
//		var tp = MacroUtil.getConstTypePath(serviceClass);
//		var serviceType = ClassMacroTools.serviceType(serviceClass);
//		var pe = priority != null ? priority : macro $v{0};
//		return macro {
//			var temp = $self;
//			var index = temp.indexOf($serviceType);
//			if(index < 0) {
//				temp.add(new #if !ecx_macro_debug @:pos($v{serviceClass.pos}) #end $tp, $pe);
//			}
//			else {
//				@:privateAccess temp._priorities[index]
//			}
//		}
//	}

//	public function indexOf(type:ServiceType):Int {
//		for(i in 0..._services.length) {
//			if(@:privateAccess _services[i].__getType() == type) {
//				return i;
//			}
//		}
//		return -1;
//	}
}