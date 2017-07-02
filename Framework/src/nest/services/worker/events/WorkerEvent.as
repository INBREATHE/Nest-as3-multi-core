/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.worker.events
{
import flash.events.Event;

public class WorkerEvent extends Event
{
	public static const
		RUNNING			:String = "WORKER_RUNNING"
	,	READY			:String = "WORKER_READY"
	,	NEW				:String = "WORKER_NEW"
	,	TERMINATED		:String = "WORKER_TERMINATED"
	,	MODE_CHANGED	:String = "WORKER_MODE_CHANGED";

	public function WorkerEvent(type:String)
	{
		super(type);
	}
}
}