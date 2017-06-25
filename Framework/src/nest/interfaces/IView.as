/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
public interface IView
{
	function registerObserver( notificationName:String, observer:IObserver ) : void;

	function notifyObservers( note:INotification ) : void;
	function registerMediator( mediator:IMediator ) : void;
	function registerMediatorAdvance( mediator:IMediator ) : void;
	function retrieveMediator( mediatorName:String ) : IMediator;
	function removeMediator( mediatorName:String ) : IMediator;
	function hasMediator( mediatorName:String ) : Boolean;
}
}