/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface IProxy extends INotifier
{
	function getProxyName():String;
	function setData(data:Object):void;
	function getData():Object;
	function onRegister():void;
	function onRemove():void;
}
}