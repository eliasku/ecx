package ecx.reporting;

#if ecx_report

import haxe.Json;
import sys.io.File;

@:final
class EcxBuildReport {

	static var _components:Array<String> = [];
	static var _wires:Array<EcxWiresMeta> = [];
	static var _families:Array<EcxFamilyMeta> = [];

	public static function addComponent(path:String) {
		_components.push(path);
	}

	public static function addFamily(name:String, system:String, components:Array<String>, optional:Array<String>) {
		_families.push({
			name: name,
			system: system,
			components: components,
			optional: optional
		});
	}

	public static function trackWire(service:String, dependency:String) {
		for (wire in _wires) {
			if (wire.service == service) {
				wire.dependencies.push(dependency);
				return;
			}
		}
		_wires.push({
			service: service,
			dependencies: [dependency]
		});
	}

	public static function save() {
		var content = Json.stringify({
			families: _families
		});
		File.saveContent("report.json", content);

		for (f in _families) {
			for (c in f.components) {
				if (_components.indexOf(c) < 0) {
					_components.push(c);
				}
			}
		}

		var htmlTableContent:String = '';
		var htmlComponentsHeader = '';
		for (c in _components) {
			htmlComponentsHeader += '<th>$c</th>';
		}
		var htmlTableHeader = '<tr><th></th>$htmlComponentsHeader</tr>';
		var htmlTableLines = '';
		for (f in _families) {
			var line = '<td>${f.system + ":" + f.name}</td>';
			for (c in _components) {
				var has = f.components.indexOf(c) >= 0;
				line += '<td>${has ? "X" : ""}</td>';
			}
			htmlTableLines += '<tr>$line</tr>';
		}

		var html = "<html><head></head><body>" +
		'<table style="width:100%">$htmlTableHeader $htmlTableLines</table>' +
		"</body></html>";

		File.saveContent("ecs_matrix.html", html);

		var services = [];
		for (w in _wires) {
			for (wd in w.dependencies) {
				if (services.indexOf(wd) < 0) {
					services.push(wd);
				}
			}
		}

		var htmlTableContent:String = '';
		var htmlServicesHeader = '';
		for (s in services) {
			htmlServicesHeader += '<th>$s</th>';
		}
		var htmlTableHeader = '<tr><th></th>$htmlServicesHeader</tr>';
		var htmlTableLines = '';
		for (w in _wires) {
			var line = '<td>${w.service}</td>';
			for (s in services) {
				var has = w.dependencies.indexOf(s) >= 0;
				line += '<td>${has ? "X" : ""}</td>';
			}
			htmlTableLines += '<tr>$line</tr>';
		}

		var html = "<html><head></head><body>" +
		'<table style="width:100%">$htmlTableHeader $htmlTableLines</table>' +
		"</body></html>";

		File.saveContent("ecs_wires.html", html);
	}
}

typedef EcxFamilyMeta = {
	var name:String;
	var system:String;
	var components:Array<String>;
	var optional:Array<String>;
}

typedef EcxWiresMeta = {
	var service:String;
	var dependencies:Array<String>;
}

#end