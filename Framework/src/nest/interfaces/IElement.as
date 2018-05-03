/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
	import nest.Environment;

public interface IElement
{
	function set order(value:int):void;
	function get order():int;
	function get env():Environment;
}
	
}