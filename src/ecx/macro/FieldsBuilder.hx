package ecx.macro;

#if macro

import haxe.macro.Expr;

@:final
class FieldsBuilder {

    public static function buildAndPush(fields:Array<Field>, block:Expr) {
        pushFields(fields, build(block));
    }

    public static function appendMacroClass(fields:Array<Field>, typeDefinition:TypeDefinition) {
        pushFields(fields, typeDefinition.fields);
    }

    public static function pushFields(fields:Array<Field>, newFields:Array<Field>) {
        for(newField in newFields) {
            fields.push(newField);
        }
    }

    public static function build(block:Expr):Array<Field> {
        var fields:Array<Field> = [];
        var exprs = switch(block.expr) {
            case ExprDef.EBlock(x): x;
            case ExprDef.EFunction(_, _): [block];
            case ExprDef.EVars(_): [block];
            default: throw "Bad expression for building";
        }
        var metas = [];
        for (expr in exprs) {
            switch (expr.expr) {
                case ExprDef.EMeta(meta, e):
                    metas.push(meta);
                case ExprDef.EVars(vars):
                    for (v in vars) {
                        fields.push({
                            name: getFieldName(v.name),
                            doc: null,
                            access: getAccess(v.name),
                            kind: FieldType.FVar(v.type, v.expr),
                            pos: v.expr.pos,
                            meta: metas
                        });
                    }
                    metas = [];
                case ExprDef.EFunction(name, f):
                    fields.push({
                        name: getFieldName(name),
                        doc: null,
                        access: getAccess(name),
                        kind: FieldType.FFun(f),
                        pos: f.expr.pos,
                        meta: metas
                    });
                    metas = [];
                default:
            }
        }
        return fields;
    }

    static function getAccess(name:String):Array<Access> {
        var result = [];
        for (token in name.split("_X")) {
            var access = switch (token) {
                case "public": Access.APublic;
                case "private": Access.APrivate;
                case "static": Access.AStatic;
                case "override": Access.AOverride;
                case "dynamic": Access.ADynamic;
                case "inline": Access.AInline;
                default: null;
            }
            if (access != null) {
                result.push(access);
            }
        }
        return result;
    }

    static function getFieldName(name:String):String {
        var parts = name.split("_X");
        return parts[parts.length - 1];
    }
}

#end