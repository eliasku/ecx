package ecx;

import ecx.types.ServiceSpec;
import ecx.types.ServiceType;

/**
	Service is injectable world-scope type.

	Initialization steps:
	- services are instantiated by passing to world-configuration
	- services are wired with each other
	- services are initialized
	- systems are able to be updated (if not IDLE)

	@see ecx.Wire
**/

#if !macro
@:autoBuild(ecx.macro.ServiceBuilder.build())
#end
@:core
class Service {

	var world(default, null):World;

	function initialize() {}

	function __serviceType():ServiceType {
		return ServiceType.INVALID;
	}

	function __serviceSpec():ServiceSpec {
		return ServiceSpec.INVALID;
	}

	function __allocate() {}
	function __inject() {}
}
