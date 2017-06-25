/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.injector
{
import flash.utils.Dictionary;
import flash.utils.describeType;

import nest.interfaces.INotifier;

public final class Injector
{
	static private const INJECT:String = "Inject";

	static private const _core_targets		: Dictionary 	= new Dictionary();
	static private const _core_source		: Dictionary 	= new Dictionary();

    //==================================================================================================
    static public function mapSource( name:String, instance:INotifier ):void {
    //==================================================================================================
        const multitonKey   : String = instance.getMultitonKey();
		var sourcesCore     : Dictionary = _core_source[ multitonKey ] as Dictionary;
		if(sourcesCore == null) {
			sourcesCore = new Dictionary();
			_core_source[ multitonKey ] = sourcesCore;
		}

//		!Worker.current.isPrimordial &&
// 		trace("> mapSource:", name, instance);
		sourcesCore[ name ] = instance;
	}

    //==================================================================================================
    static public function mapTarget( classRef:Class, multitonKey:String ):void {
    //==================================================================================================
        const sourcesCore 	: Dictionary = _core_source[multitonKey] as Dictionary;
		const description	: XML = describeType(classRef);
		const variablesList	: XMLList = description..variable as XMLList;
		const variables		: Vector.<InjectVar> = new Vector.<InjectVar>();
//			if(!Worker.current.isPrimordial) {
//				trace("> mapTarget:", classRef);
//			}

		if(variablesList.length() > 0)
        {
            var metadata		: XMLList;
            var variableXML		: XML;
            var variableMETA	: XMLList;
            var variableType	: String;
            var variableName	: String;
            var variablesCount	: int;
            var variableINJECT	: Boolean;
            var foundInjection	: Boolean = false;
            var injectVar       : InjectVar;

            for each (variableXML in variablesList)
            {
				variableType    = variableXML.@type;
				metadata        = variableXML..metadata;
				variableMETA    = metadata.(@name == INJECT);
                variablesCount  = variableMETA.length();
				variableINJECT  = variablesCount > 0;

				if(variableINJECT || (sourcesCore && sourcesCore[variableType])) {
                    variableName = variableXML.@name;
                    injectVar = new InjectVar(variableName, variableType);
//						trace("\t", classRef, variableName, variableType);
					variables.push(injectVar);
                    foundInjection = true;
				}
			}
//				if(!Worker.current.isPrimordial)
//					trace("> mapTarget: foundInjection:", foundInjection);

			if(foundInjection)
			{
				var targets : Dictionary = _core_targets[ multitonKey ] as Dictionary;
				if(targets == null) {
					targets = new Dictionary();
//						trace("> mapTarget: new targets for key =", multitonKey);
					_core_targets[ multitonKey ] = targets;
				}
				targets[ classRef ] = variables;
			}
		}
	}

    //==================================================================================================
    static public function mapTargets(classes:Vector.<Class>, multitonKey:String):void {
    //==================================================================================================
        var description		: XML;
		var variablesList	: XMLList;
		var variables		: Vector.<InjectVar>;
		var variablesCount	: uint;
		var variableXML		: XML;
        var variableMETA	: XMLList;
        var variableINJECT	: Boolean = false;
        var variableType	: String;
        var variableName	: String;
		var classRef		: Class;

		var targets:Dictionary = _core_targets[ multitonKey ];
		if(targets == null) {
			targets = new Dictionary();
			_core_targets[ multitonKey ] = targets;
		}

        var source:Dictionary = _core_source[ multitonKey ];
        var injectVar:InjectVar;
//			trace(multitonKey, ">\t mapTargets", classes);

		for each (classRef in classes)
		{
			description = describeType(classRef);
			variablesList = description..variable as XMLList;
			variablesCount = variablesList.length();

//				trace(">\t\t mapTarget", variablesCount, classRef);

			if(variablesCount > 0) {
				variables = new Vector.<InjectVar>();
				for each (variableXML in variablesList) {
                    variableMETA = variableXML..metadata;
                    variableINJECT = variableMETA != null && variableMETA.length() > 0;
                    variableType = variableXML.@type;
					if(variableINJECT || (source[ variableType ])) {
                        variableName = variableXML.@name;
                        injectVar = new InjectVar(variableName, variableType);
						variables.push(injectVar);
//							trace(">\t\t\t variables", variableXML.@name);
					}
				}
				targets[ classRef ] = variables;
			}
		}
		// SAME BUT SHORTER and more expensive
		// classes.forEach(function(clss:Class, index:uint, vec:Vector.<Class>):void { mapTarget(clss) });
	}

    //==================================================================================================
    static public function mapInject( object:INotifier ):void {
    //==================================================================================================
        const multitonKey   : String = object.getMultitonKey();
        const description	: XML = describeType(object);
		const variablesList	: XMLList = description..variable as XMLList;
		const source		: Dictionary = _core_source[ multitonKey ];

//		trace("> mapInject:", object, variablesList);
		if(variablesList.length() > 0) {

            var
				variableXML		: XML
			, 	metadata		: XMLList
			,	variableMETA    : XMLList
            ,	variableINJECT	: Boolean
            ,	variablesCount	: int
            ,	variableType	: String
            ,	variableName	: String
			,	sourceObject	: Object
			;

			for each (variableXML in variablesList)
			{
                metadata = variableXML.metadata;
                variableMETA = metadata.(@name == INJECT);
				if(variableMETA != null)
				{
					variablesCount = variableMETA.length();
					variableINJECT = variablesCount > 0;
					variableType = variableXML.@type;
					sourceObject = source[ variableType ];
//					trace("\t", variableINJECT, variableType, sourceObject);
					if(variableINJECT && sourceObject) {
						variableName = variableXML.@name;
						object[ variableName ] = sourceObject;
					}
				}
			}
		}
	}

    //==================================================================================================
	static public function hasTarget( classRef:Class, multitonKey:String ):Boolean {
    //==================================================================================================
		const targets : Dictionary = _core_targets[ multitonKey ];
//			trace("\ttargets:", targets);
//			if(targets) trace("targets[classRef]", targets[classRef]);
		return targets && !(targets[ classRef ] == null);
	}

    //==================================================================================================
	static public function injectTo( classRef:Class, object:INotifier ):void {
    //==================================================================================================
        const multitonKey   : String = object.getMultitonKey();
		const targets       : Dictionary = _core_targets[ multitonKey ];
//			trace(multitonKey, "> injectTo:", classRef, object);
		if(targets != null)
		{
			const source : Dictionary = _core_source[ multitonKey ];
			if(source != null)
			{
				const variables	: Vector.<InjectVar> = targets[ classRef ];
				var counter 	: uint = variables.length;
				var variable	: InjectVar;
				var varName		: String = "";
				var varType		: String = "";
				while(counter-- > 0) {
					variable = variables[ counter ];
					varName = variable.name;
					varType = variable.type;
//						trace("> injectTo:", variable);

					object[ varName ] = source[ varType ];
				}
			}
			else throw new Error("No source to inject in this core:" + multitonKey);
		}
		else throw new Error("No targets to inject in this core:" + multitonKey);
	}

    //==================================================================================================
    public static function unmapTarget( clss:Class, multitonKey:String ):void {
    //==================================================================================================
        const targets : Dictionary = _core_targets[ multitonKey ];
		if(targets && targets[ clss ]) delete targets[ clss ];
	}

    //==================================================================================================
    public static function unmapSource( name:String, multitonKey:String ):void {
    //==================================================================================================
        const source : Dictionary = _core_source[ multitonKey ];
		if(source[ name ]) delete source[ name ];
	}
}
}

internal final class InjectVar {
	private var _name:String = "";
	public function get name():String { return _name; }

	private var _type:String = "";
	public function get type():String { return _type; }

	public function InjectVar(name:String, type:String)
	{
		this._type = type;
		this._name = name;
	}
}