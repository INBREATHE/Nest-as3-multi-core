/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface IScrollItem
{
	function isLocked():Boolean;
	function isLockedAt(index:uint):Boolean;
	function show():void;
	function hide():void;
}
}
