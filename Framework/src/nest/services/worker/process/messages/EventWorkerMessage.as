/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.worker.process.messages
{
[RemoteClass]
public class EventWorkerMessage
{
	private var
		_id		:int
	,	_data	:*
	;

	public function EventWorkerMessage(id:int = 0, data:* = null)
	{
		this.id = id;
		this.data = data;
	}

	public function get data():* { return _data; }
	public function get id():int { return _id; }

	public function set data(value:*):void { _data = value; }
	public function set id(value:int):void { _id = value; }
}
}