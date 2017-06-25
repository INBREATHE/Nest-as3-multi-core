/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.patterns.observer
{
import nest.interfaces.INotification;
import nest.interfaces.IObserver;

public class Observer implements IObserver
{
	private var notify:Function;
	private var context:Object;
	private var advance:Boolean = false;

	public function Observer( notifyMethod:Function, notifyContext:Object, advance:Boolean = false ) {
		this.notify = notifyMethod;
		this.context = notifyContext;
		this.advance = advance;
	}

	public function notifyObserver( notification:INotification ):void {
		if(advance){ 
			const paramsCount:uint = notify.length;
			switch(paramsCount) {
			case 0: default: notify.call( context ); break;
			case 1: notify.call( context, notification.getBody() ); break;
			case 2: notify.call( context, notification.getBody(), notification.getType() ); break;
		}}
		else {
			notify.call( context, notification );
		}
	}

	public function compareNotifyContext( object:Object ):Boolean {
		return object === this.context;
	}
}
}