/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface IModel extends ILanguageDependent
{
	function registerProxy		( proxyClass:Class ) 	: IProxy;
	function retrieveProxy		( proxyClass:Class ) 	: IProxy;
	function removeProxy		  ( proxyClass:Class ) 	: IProxy;
	function hasProxy			    ( proxyClass:Class ) 	: Boolean;
}
}