/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.popup
{
public final class PopupEventData
{
	public var body:Object;
	public var type:String;

	private var _callback:Function;
	public function PopupEventData(body:Object, type:String = null)
	{
		this.type = type;
		this.body = body;
	}
	
	public function onComplete(callback:Function):PopupEventData {
		_callback = callback;
		return this;
	}

	public function get callback():Function{ return _callback; }

}
}