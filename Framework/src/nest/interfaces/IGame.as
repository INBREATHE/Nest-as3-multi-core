/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
import flash.geom.Point;
public interface IGame
{
	function init(actions:Vector.<String>):void;
	function show():void;
	function hide(callback:Function = null):void;
	function update(data:Object):void;
	function build(data:Object):void;
	function reset():void;

	function touchstart(position:Point):void;
	function touchmove(delta:Point):void;
	function touchend(position:Point):Boolean;

	function tap():void;
}
}
