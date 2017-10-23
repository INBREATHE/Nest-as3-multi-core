/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
import nest.patterns.observer.NFunction;

public interface IMediator extends INotifier
{
	function getMediatorName():String;
	function getViewComponent():Object;
	function setViewComponent(value:Object):void;
	function get listNotifications():Vector.<String>;
	function get listNFunctions():Vector.<NFunction>;
	function handleNotification(note:INotification):void;
	function onRegister():void;
	function onRemove():void;
}
}