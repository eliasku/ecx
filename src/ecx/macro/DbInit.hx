package ecx.macro;
//
//import ecx.macro.WorldTypeBuilder.WorldTypeInfo;
//import haxe.macro.Expr;
//import haxe.macro.Context;
//
//class DbInit {
//
//	macro public static function registerList(db:ExprOf<Database>) {
//		var cache = @:privateAccess WorldTypeBuilder.CACHE;
//		var pos = Context.currentPos();
//		var exprs:Array<Expr> = [];
//		for(kind in cache.keys()) {
//			for(key in cache[kind].keys()) {
//				var info:WorldTypeInfo = cache[kind][key];
//				var typeKind = info.kind;
//				var typePath = info.path;
//				var typeId = info.id;
//				var typeIndex = info.index;
//				exprs.push(macro @:privateAccess $db.register($v{typePath}, $v{typeKind}, $v{typeId}, $v{typeIndex}));
//			}
//		}
//		return macro $b{exprs};
//	}
//}
