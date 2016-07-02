import hxmake.idea.IdeaPlugin;
import hxmake.haxelib.HaxelibPlugin;

using hxmake.haxelib.HaxelibPlugin;

class EcxMake extends hxmake.Module {

	function new() {
		config.description = "ECX entity-component-system framework";
		config.version = "0.0.1";
		config.classPath = ["src"];
		config.testPath = ["test"];
		config.dependencies = [
			"utest" => "haxelib"
		];

		apply(HaxelibPlugin);
		apply(IdeaPlugin);

		library();
	}
}