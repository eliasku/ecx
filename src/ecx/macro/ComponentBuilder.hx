package ecx.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class ComponentBuilder {

	public static function build():Array<Field> {
		var cls:ClassType = Context.getLocalClass().get();
		var pos = Context.currentPos();
		var fields:Array<Field> = Context.getBuildFields();
		var implementation:Bool = MacroUtil.hasInterface(cls, "ecx.IComponent");

		var compData = getComponentData(cls);
		if(compData == null) {
			return null;
		}

		MacroBuildDebug.printComponent(compData);
		var typeId = Context.makeExpr(compData.typeId, pos);
		var exprs = null;
		if(implementation) {
			exprs = macro function public_X__componentType() { return new ecx.types.ComponentType($typeId); };
		}
		else {
			exprs = macro function public_Xoverride_X__componentType() { return new ecx.types.ComponentType($typeId); };
		}
		FieldsBuilder.buildAndPush(fields, exprs);

		var componentExpr = macro var public_Xstatic_Xinline_X__COMPONENT = new ecx.types.ComponentType($typeId);
		FieldsBuilder.buildAndPush(fields, componentExpr);
		return fields;
	}

	static function getComponentData(classType:ClassType):MacroComponentData {
		if(classType.meta.has(ServiceBuilder.META_CORE)) {
			return null;
		}

		// Look up the ID, otherwise generate one
		var fullName = MacroUtil.getFullNameFromBaseType(classType);

		var componentData = MacroComponentCache.get(fullName);
		if(componentData != null) {
			return componentData;
		}

		componentData = new MacroComponentData(fullName);
		MacroComponentCache.set(componentData);
		return componentData;
	}



}

#end