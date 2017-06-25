/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker.messages
{
	import nest.modules.pipes.messages.Message;

	[RemoteClass]
	public final class WorkerResponceMessage extends Message
	{
		public function WorkerResponceMessage(responce:String="", data:Object=null)
		{
			super(Message.NORMAL, responce, data);
		}
		
		public function getResponce():String { return String(getHeader()); }
	}
}