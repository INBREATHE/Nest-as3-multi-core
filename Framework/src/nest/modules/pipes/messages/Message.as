package nest.modules.pipes.messages
{
	import nest.modules.pipes.interfaces.IPipeMessage;
	import nest.utils.UIDUtil;

	/**
	 * Pipe Message.
	 * <P>
	 */ 
	[RemoteClass]
	public class Message implements IPipeMessage
	{
		public static const BASE	: String = "pipe-message/";
		public static const NORMAL 	: String = BASE + "normal/";

		public var body			: Object;
		public var header		: Object;
		public var type			: String;
		public var pipeID		: uint;
		public var messageID	: String;

		public function Message(type:String, header:Object = null, body:Object = null )
		{
			setBody( body );
			setHeader( header );

			this.type = type;
			this.messageID = UIDUtil.create();
		}
		
		public function getType():String { return this.type; }

		public function getHeader():Object { return this.header; }
		public function setHeader( header:Object ):void { this.header = header;	}
		
		public function getBody():Object { return body; }
		public function setBody( body:Object ):void { this.body = body; }

		public function getPipeID():uint { return this.pipeID; }
		public function setPipeID(value:uint):void { this.pipeID = value; }
		
		public function getMessageID():String { return this.messageID; }
	}
}