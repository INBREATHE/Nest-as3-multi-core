/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.patterns.observer
{
import nest.interfaces.INotification;

public class Notification implements INotification
{
	private var name	: String;
	private var body	: Object;
	private var type	: String;

	public function Notification( name:String, body:Object=null, type:String = null ) {
		this.name = name;
		this.body = body;
		this.type = type;
	}

	public function getName():String { return name; }
	public function getBody():Object { return body; }
	public function getType():String { return type; }

	public function setBody( body:Object ):void { this.body = body; }

	public function toString():String
	{
		var msg:String = "Notification Name: " + getName();
		msg += "\nBody:" + (( body == null ) ? "null" : body.toString());
		return msg;
	}
}
}