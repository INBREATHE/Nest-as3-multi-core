package nest.modules.pipes.interfaces
{
	/** 
	 * Pipe Message Interface.
	 * <P>
	 * <code>IPipeMessage</code>s are objects written into to a Pipeline,
	 * composed of <code>IPipeFitting</code>s. The message is passed from 
	 * one fitting to the next in synchronous fashion.</P>
	 * <P>
	 */
	public interface IPipeMessage
	{
		function getType():String;

		// Get the header of this message
		function getHeader():Object;

		// Set the header of this message
		function setHeader(header:Object):void;
		
		// Get the body of this message
		function getBody():Object;

		// Set the body of this message
		function setBody(body:Object):void;
		
		function getPipeID():uint;
		function setPipeID(value:uint):void;

		function getResponsePipeID():uint;
		function setResponsePipeID(value:uint):void;

		function getMessageID():String;
	}
}