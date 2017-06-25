/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.patterns.mediator
{
import flash.utils.getQualifiedClassName;

import nest.interfaces.IMediator;
import nest.interfaces.INotification;
import nest.patterns.observer.NFunction;
import nest.patterns.observer.Notifier;

public class Mediator extends Notifier implements IMediator
{
	private static const ERROR_NO_CHILD:String = "There is no child function";

	protected var mediatorName:String;
	protected var viewComponent:Object;

	public function Mediator( viewComponent:Object=null ) {
		this.mediatorName = getQualifiedClassName(this);
		if( viewComponent != null ) this.viewComponent = viewComponent;
	}

	public function getMediatorName()							: String 	{ return mediatorName; }
	public function setViewComponent(value:Object)				: void 		{ this.viewComponent = value; }
	public function getViewComponent()							: Object 	{ return viewComponent; }
	public function handleNotification(note:INotification)		: void 		{ }
	public function onRegister()								: void 		{ }
	public function onRemove()									: void 		{ }

	public function listNotificationInterests()					: Vector.<String> 		{ return new Vector.<String>(); }
	public function listNotificationsFunctions()				: Vector.<NFunction> 	{ return new Vector.<NFunction>(); }

	protected function applyViewComponentMethod(name:String, body:Object):void {
		const func:Function = viewComponent[name] as Function;
		if(func != null) {
			if(func.length == 1) func.apply(viewComponent, body);
			else func.call(viewComponent);
		} else throw new Error(ERROR_NO_CHILD);
	}
}
}