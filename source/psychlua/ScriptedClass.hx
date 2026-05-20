package psychlua;

import crowplexus.hscript.Expr;
import crowplexus.hscript.Interp;

interface IScriptCustomConstructor {
	public function hnew(args:Array<Dynamic>):Dynamic;
}

interface IScriptCustomBehaviour {
	public function hget(name:String):Dynamic;
	public function hset(name:String, val:Dynamic):Dynamic;
}

class ScriptClassHandler implements IScriptCustomConstructor {
	public var ogInterp:Interp;
	public var name:String;
	public var fields:Array<Expr>;
	public var extend:String;
	public var interfaces:Array<String>;

	public function new(ogInterp:Interp, name:String, fields:Array<Expr>, ?extend:String, ?interfaces:Array<String>) {
		this.ogInterp = ogInterp;
		this.name = name;
		this.fields = fields;
		this.extend = extend;
		this.interfaces = interfaces == null ? [] : interfaces;
	}

	public function hnew(args:Array<Dynamic>):Dynamic {
		var childInterp = new Interp();

		for (key => value in ogInterp.variables) childInterp.variables.set(key, value);
		for (key => value in ogInterp.imports) childInterp.imports.set(key, value);
		for (key => value in ogInterp.customClasses) childInterp.customClasses.set(key, value);

		var superCl:Class<Dynamic> = null;
		if (extend != null) {
			var fromVar:Dynamic = ogInterp.variables.get(extend);
			if (fromVar == null) fromVar = ogInterp.imports.get(extend);
			if (Std.isOfType(fromVar, Class)) superCl = cast fromVar;
			else {
				superCl = Type.resolveClass(extend);
				if (superCl == null) superCl = Type.resolveClass(extend + '_HSX');
			}
			if (superCl == null) @:privateAccess ogInterp.error(ECustom('ScriptedClass: cannot resolve superclass "$extend"'));
		}

		var instance:ScriptTemplateBase;
		if (superCl != null) {
			var superInstance:Dynamic = Type.createInstance(superCl, args);
			instance = new ScriptTemplateBase();
			instance.__superInstance = superInstance;
		} else {
			instance = new ScriptTemplateBase();
		}

		instance.__interp = childInterp;
		childInterp.variables.set("this", instance);

		for (fieldExpr in fields) {
			switch (crowplexus.hscript.Tools.expr(fieldExpr)) {
				case EVar(name, _, init):
					var initVal:Dynamic = null;
					if (init != null) @:privateAccess initVal = childInterp.expr(init);
					childInterp.variables.set(name, initVal);
				default:
					@:privateAccess childInterp.exprReturn(fieldExpr);
			}
		}

		if (instance.__superInstance != null) childInterp.variables.set("super", instance.__superInstance);

		var ctorFn:Dynamic = childInterp.variables.get("new");
		if (ctorFn != null) Reflect.callMethod(null, ctorFn, args);

		return instance;
	}
}

class ScriptTemplateBase implements IScriptCustomBehaviour {
	public var __interp:Interp;
	public var __superInstance:Dynamic;

	public function new() {}

	public function hget(name:String):Dynamic {
		if (__interp == null) return Reflect.getProperty(this, name);
		var getter:Dynamic = __interp.variables.get('get_$name');
		if (getter != null && Reflect.isFunction(getter)) return getter();
		if (__interp.variables.exists(name)) return __interp.variables.get(name);
		if (__superInstance != null) return Reflect.getProperty(__superInstance, name);
		return Reflect.getProperty(this, name);
	}

	public function hset(name:String, val:Dynamic):Dynamic {
		if (__interp == null) {
			Reflect.setProperty(this, name, val);
			return val;
		}
		var setter:Dynamic = __interp.variables.get('set_$name');
		if (setter != null && Reflect.isFunction(setter)) {
			setter(val);
			return val;
		}
		if (__interp.variables.exists(name)) {
			__interp.variables.set(name, val);
			return val;
		}
		if (__superInstance != null) {
			Reflect.setProperty(__superInstance, name, val);
			return val;
		}
		__interp.variables.set(name, val);
		return val;
	}
}
