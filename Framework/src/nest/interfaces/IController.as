/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface IController
{
	function registerCommand( notificationName : String, commandClassRef : Class ) : void;
	function registerPoolCommand( notificationName : String, commandClassRef : Class ) : void;
	function registerCountCommand( notificationName : String, commandClassRef : Class, replyCount:int ) : void;
	function executeCommand( notification : INotification ) : void;
	function removeCommand( notificationName : String ) : Boolean;
	function hasCommand( notificationName:String ) : Boolean;
}
}