/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker.messages
{
import nest.modules.pipes.messages.Message;
import nest.modules.pipes.messages.Message;

[RemoteClass]
	public final class WorkerResponseMessage extends Message
	{
		public function WorkerResponseMessage(request:String="", data:Object=null, responsePipeID:uint = 0)
		{
			super(Message.WORKER, request, data);
			setResponsePipeID(responsePipeID);
		}

		public function getResponse():String { return String(getHeader()); }
	}
}