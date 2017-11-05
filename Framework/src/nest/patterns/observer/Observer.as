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
	private var _notify:Function;
	private var _context:Object;
	private var _advance:Boolean = false;

	public function Observer( notifyMethod:Function, notifyContext:Object, advance:Boolean = false ) {
		this._notify = notifyMethod;
		this._context = notifyContext;
		this._advance = advance;
	}

	public function notifyObserver( notification:INotification ):void {
//		trace("> \t\t _context =", _context, "_notify =", _notify);
		if(_advance) {
			const paramsCount:uint = _notify.length;
			switch(paramsCount) {
			case 0: default: _notify.call( _context ); break;
			case 1: _notify.call( _context, notification.getBody() ); break;
			case 2: _notify.call( _context, notification.getBody(), notification.getType() ); break;
			case 3: _notify.call( _context, notification.getName(), notification.getBody(), notification.getType() ); break;
		}}
		else {
			_notify.call( _context, notification );
		}
	}

	public function compareNotifyContext( object:Object ):Boolean {
		return object === this._context;
	}
}
}