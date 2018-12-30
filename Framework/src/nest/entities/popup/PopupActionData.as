/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.popup
{
public final class PopupActionData
{
	public var body:Object;
	public var type:String;

	public function PopupActionData( body:Object, type:String = null )
	{
		this.type = type;
		this.body = body;
	}
}
}