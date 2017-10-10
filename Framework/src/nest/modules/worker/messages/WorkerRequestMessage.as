/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker.messages
{
import nest.modules.pipes.messages.Message;

	[RemoteClass]
	public class WorkerRequestMessage extends Message
	{
		/**
		 * This message always must be answerred (by sending WorkerResposeMessage) if it going from Master to worker
		 * because there is a queue of request messages going from Master to worker (triggered by __complete in WorkerModule)
		 * and execution of next message on Master happens only when WorkerJunction received WorkerResponseMessage
		 */
		public function WorkerRequestMessage(request:String="", data:Object=null, responsePipeID:uint = 0)
		{
			super(Message.WORKER, request, data);
			setResponsePipeID(responsePipeID);
		}

		public function getRequest():String { return String(getHeader()); }
		public function copy():WorkerRequestMessage { 
			const result:WorkerRequestMessage = new WorkerRequestMessage(getRequest(), getBody(), getResponsePipeID());
			result.setPipeID(getPipeID());
			return result; 
		}
	}
}