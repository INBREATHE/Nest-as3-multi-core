/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface IModel
{
	function registerProxy		( proxy:Class ) 		: void;
	function retrieveProxy		( proxyName:String ) 	: IProxy;
	function removeProxy		( proxyName:String ) 	: IProxy;
	function hasProxy			( proxyName:String ) 	: Boolean;
}
}