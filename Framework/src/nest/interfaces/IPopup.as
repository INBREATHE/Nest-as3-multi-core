/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface IPopup
{
	function setup(data:Object):void;
	function localize(data:XMLList):void;
	function prepare(params:Object):void;
	function show():void;
	function hide(next:Function):void;

	function get command():String;
	function set commands(value:Array):void;
}
}
