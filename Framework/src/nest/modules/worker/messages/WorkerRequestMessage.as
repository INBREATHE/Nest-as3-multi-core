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
		public function WorkerRequestMessage(request:String="", data:Object=null, responce:Object=null )
		{
			const header:Object = { request:request, responce:responce };
			super(Message.NORMAL, header, data);
		}
		
		public function getRequest():String { return this.header.request; }
		
		public function getResponce():*	{ return this.header.responce; }
		public function setResponce(value:String):void  { this.header.responce = value; }
	}
}