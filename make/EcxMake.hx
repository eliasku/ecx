import hxmake.test.SetupTask;
import hxmake.test.TestTask;
import hxmake.haxelib.HaxelibExt;
import hxmake.idea.IdeaPlugin;
import hxmake.haxelib.HaxelibPlugin;

using hxmake.haxelib.HaxelibPlugin;

class EcxMake extends hxmake.Module {

	function new() {
		config.classPath = ["src"];
		config.testPath = ["test"];
		config.devDependencies = [
			"utest" => "haxelib"
		];

		apply(HaxelibPlugin);
		apply(IdeaPlugin);

		this.library(function(ext:HaxelibExt) {
			ext.config.version = "0.1.1";
			ext.config.description = "Haxe Entity System library";
			ext.config.url = "https://github.com/eliasku/ecx";
			ext.config.tags = ["entity", "component", "system", "cross"];
			ext.config.contributors = ["eliasku"];
			ext.config.license = "MIT";
			ext.config.releasenote = "Fix compatibility";

			ext.pack.includes = ["src", "haxelib.json", "README.md", "CHANGELOG.md"];
		});

		var testTask = new TestTask();
		testTask.debug = true;
		testTask.targets = ["neko", "swf", "node", "js", "cpp", "java", "cs"];
		testTask.libraries = ["ecx"];
		testTask.defines.push("eval-stack");
		testTask.defines.push("ecx_debug");
		task("test", testTask);
	}
}
