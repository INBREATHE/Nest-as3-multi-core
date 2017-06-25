/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.worker.process
{
import nest.modules.pipes.interfaces.IPipeMessage;

public final class WorkerTask
{
	public function WorkerTask(id:int, data:IPipeMessage = null)
	{
		this._data = data;
		this._id = id;
	}

	public static const
		READY 			: int = 0
	,	SYNC_DB 		: int = 10
	,	SIGNAL	 		: int = 11
	,	MESSAGE	 		: int = 12
	,	REQUEST 		: int = 13
	,	PROGRESS 		: int = 14
	,	COMPLETE 		: int = 15
	,	TERMINATE 		: int = 16
	;

	private var _id:int;
	private var _data:IPipeMessage;

	public function get id():int { return _id; }
	public function get data():IPipeMessage { return _data; }
}
}

