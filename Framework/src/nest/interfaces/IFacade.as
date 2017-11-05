/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface IFacade
{
	function get key():String;

	function get currentLanguage():String;
	function set currentLanguage(value:String):void;

	function registerProxy		( proxyClass : Class ) : void;
	function removeProxy		( proxyClass : Class ) : IProxy;
	function hasProxy			( proxyClass : Class ) : Boolean;
	function getProxy			( proxyClass : Class ) : IProxy;

	function registerCommand	( commandName : String, commandClassRef : Class ) : void;
	function removeCommand		( commandName : String ) : void; 
	function hasCommand			( commandName : String ) : Boolean;

	function registerProcess	( processClassRef : Class ) : void;
	function removeProcess		( processClassRef : Class ) : void;
	function hasProcess			( processClassRef : Class ) : Boolean;

	function registerPoolCommand		( commandName : String, commandClassRef : Class ) : void;
	function registerCountCommand		( commandName : String, commandClassRef : Class, count:int ) : void;

	function registerMediator	( name:String, mediator : IMediator ) : void;
	function removeMediator		( mediatorName : String ) : IMediator;
	function hasMediator		( mediatorName : String ) : Boolean;
	function getMediator		( mediatorName : String ) : IMediator;

	function sendNotification	( notification : INotification ):void;
	function executeCommand		( notification : INotification ):void;
	function runProcess			( notification : INotification ):void;
}
}
