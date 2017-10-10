package nest.modules.pipes.plumbing
{
	import nest.modules.pipes.interfaces.IPipeFitting;
	import nest.modules.pipes.interfaces.IPipeMessage;
	import nest.modules.pipes.plumbing.Filter;
	
	/**
	 * Pipe.
	 * <P>
	 * This is the most basic <code>IPipeFitting</code>,
	 * simply allowing the connection of an output
	 * fitting and writing of a message to that output.</P>
	 */	
	public class Pipe implements IPipeFitting
	{
		private static var serial:Number = 1;
		public static function newChannelID():uint { return serial++; }
		
		public var chainLength:uint = 0;
		
		private var
			_channelID	: uint = 0
		,	_pipeName	: String
		;

		protected var output:IPipeFitting;
		
		public function Pipe( channelID:uint )
		{
			_channelID = channelID;
		}

		/**
		 * Connect another PipeFitting to the output.
		 * 
		 * PipeFittings connect to and write to other 
		 * PipeFittings in a one-way, syncrhonous chain.</P>
		 * 
		 * @return Boolean true if no other fitting was already connected.
		 */
		public function connect( output:IPipeFitting ) : Boolean
		{
			var success:Boolean = false;
			if (this.output == null) {
				output.pipeName = this.pipeName;
				if(output is Filter) {
					output.channelID = this._channelID;
				}
				this.output = output;
				success = true;
				chainLength++;
			}
			return success;
		}
		
		/**
		 * Disconnect the Pipe Fitting connected to the output.
		 * <P>
		 * This disconnects the output fitting, returning a 
		 * reference to it. If you were splicing another fitting
		 * into a pipeline, you need to keep (at least briefly) 
		 * a reference to both sides of the pipeline in order to 
		 * connect them to the input and output of whatever 
		 * fiting that you're splicing in.</P>
		 * 
		 * @return IPipeFitting the now disconnected output fitting
		 */
		public function disconnect( ) : IPipeFitting
		{
			const disconnectedFitting:IPipeFitting = this.output;
			this.output = null;
			return disconnectedFitting;
		}
		
		/**
		 * Write the message to the connected output.
		 * 
		 * @param message the message to write
		 * @return Boolean whether any connected downpipe outputs failed
		 */
		public function write( message:IPipeMessage ) : Boolean
		{
//			trace("======> Pipe( " + pipeName + " id:" + channelID + " ).write: ouput =",output, output.pipeName, message);
			return output && output.write( message );
		}

		public function get pipeName():String { return _pipeName; }

		public function set pipeName(value:String):void { _pipeName = value; }

		public function get channelID():uint { return _channelID; }

		public function set channelID(value:uint):void { _channelID = value; }
	}
}