/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.patterns.observer
{
import flash.utils.getQualifiedClassName;

import nest.interfaces.IFacade;
import nest.interfaces.INotifier;
import nest.patterns.facade.Facade;

public class Notifier implements INotifier
{
	protected var facade:IFacade;
	public function send( notificationName:String, body:Object = null, type:String = null ):void {
		trace("> Nest -> Notifier", this, "-> send:", notificationName);
		facade.sendNotification( new Notification( notificationName, body, type ) );
	}

	// The Multiton Key for this app
	public function initializeNotifier( key:String ):void {
		facade = Facade.getInstance( key );
		if ( facade == null ) throw Error( Facade.MULTITON_MSG + " : " + getQualifiedClassName(this) );
	}

	public function exec( commandName:String, body:Object = null, type:String = null ):void {
		facade.executeCommand( new Notification( commandName, body, type ) );
	}

	public function commandExist( value:String):Boolean { return facade.hasCommand( value ); }
	public function getMultitonKey():String { return facade.key; }
}
}