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
		config.dependencies = [
			"power-of-two" => "haxelib"
		];
		config.devDependencies = [
			"utest" => "haxelib"
		];

		apply(HaxelibPlugin);
		apply(IdeaPlugin);

		library(function(ext:HaxelibExt) {
			ext.config.version = "0.1.1";
			ext.config.description = "Haxe Entity System library";
			ext.config.url = "https://github.com/eliasku/ecx";
			ext.config.tags = ["entity", "component", "system", "cross"];
			ext.config.contributors = ["eliasku"];
			ext.config.license = "MIT";
			ext.config.releasenote = "Fix compatibility";

			ext.pack.includes = ["src", "haxelib.json", "README.md", "CHANGELOG.md"];
		});

		var testTaskDependencies = new SetupTask();
		testTaskDependencies.librariesFromGit.push("power-of-two;https://github.com/eliasku/power-of-two.git");

		var tt = new TestTask();
		tt.debug = true;
		tt.targets = ["neko", "swf", "node", "js", "cpp", "java", "cs"];
		tt.libraries = ["ecx", "power-of-two"];
		task("test", tt).prepend(testTaskDependencies);
	}
}