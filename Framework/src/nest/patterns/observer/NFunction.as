/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.patterns.observer
{
public class NFunction extends Object
{
	static public const TYPE_FUNCTION	: String = "function";
	static public const TYPE_STRING		: String = "string";

	public var name		: String = "";
	public var func		: Object = null;

	public function NFunction( name:String, func:Object ) {
		this.name = name;
		this.func = func;
	}
	
	public function clear():void {
		func = null;
		name = null;
	}
}
}