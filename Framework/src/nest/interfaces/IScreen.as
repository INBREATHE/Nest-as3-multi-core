/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface IScreen extends IEntity
{
	function show():void;
	function hide(callback:Function = null):void;
	function build(content:Object):void;
	function clear():void;
	function onAdded():void;
	function onRemoved():void;
}
}
