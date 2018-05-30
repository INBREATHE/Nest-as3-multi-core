/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface IGame
{
	function show():void;
	function hide(callback:Function = null):void;
	function clear():void; // Called from GameMediator at REMOVED_FROM_STAGE handler
	function reset():void;

	function lock():void;
	function unlock():void;
}
}
