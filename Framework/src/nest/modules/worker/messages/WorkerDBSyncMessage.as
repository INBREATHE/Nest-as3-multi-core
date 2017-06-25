/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker.messages
{
	import nest.modules.pipes.messages.Message;
	
	public final class WorkerDBSyncMessage extends Message
	{
		public function WorkerDBSyncMessage(type:String = "", table:String = "", rowID:int = -1)
		{
			super(Message.NORMAL, {type:type, table:table}, rowID);
		}
		
		public function get eventType():String { return this.header.type; }
		public function get eventTable():String { return this.header.table; }
		public function get eventRowID():uint { return uint(this.body); }
	}
}