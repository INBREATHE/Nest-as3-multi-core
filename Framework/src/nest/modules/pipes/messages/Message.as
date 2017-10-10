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
		public static const WORKER 	: String = BASE + "worker/";

		public var body			: Object;
		public var header		: Object;
		public var responseID	: uint;
		public var pipeID		: uint;
		public var messageType	: String;
		public var messageID	: String;

		public function Message(messageType:String, header:Object = null, body:Object = null )
		{
			setBody( body );
			setHeader( header );

			this.messageType = messageType;
			this.messageID = UIDUtil.create();
		}
		
		public function getType():String { return this.messageType; }

		public function getHeader():Object { return this.header; }
		public function setHeader( value:Object ):void { this.header = value;	}
		
		public function getBody():Object { return body; }
		public function setBody( value:Object ):void { this.body = value; }

		public function getPipeID():uint { return this.pipeID; }
		public function setPipeID( value:uint ):void { this.pipeID = value; }

		public function getResponsePipeID():uint { return this.responseID; }
		public function setResponsePipeID(value:uint ):void { this.responseID = value; }

		public function getMessageID():String { return this.messageID; }
	}
}