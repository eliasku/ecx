package ecx.types;

class ComponentTable {

	static public function createArrayData(qualifiedClassName:String, capacity:Int):ComponentsArrayData {
		#if flash
		var vn = untyped __global__["flash.utils.getQualifiedClassName"](flash.Vector);
		var cls = untyped __global__["flash.utils.getDefinitionByName"](vn + ".<" + qualifiedClassName + ">");
		return untyped __new__(cls, capacity, true);
		#elseif cs
		var baseClass = Type.resolveClass(qualifiedClassName);
		return cast (untyped __cs__("global::System.Array.CreateInstance({0}, {1})", baseClass, capacity));
		#elseif java
		var baseClass = Type.resolveClass(qualifiedClassName);
		return cast (untyped __java__("java.lang.reflect.Array.newInstance({0}, {1})", baseClass, capacity));
		#else
		return new ComponentsArrayData(capacity);
		#end
	}

}
