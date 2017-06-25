/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface INotification
{
	function getName():String;
	function getType():String;
	function setBody( body:Object ):void;
	function getBody():Object;
	function toString():String;
}
}