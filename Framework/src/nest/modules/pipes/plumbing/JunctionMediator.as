package nest.modules.pipes.plumbing
{
	import nest.interfaces.INotification;
	import nest.modules.pipes.interfaces.IPipeFitting;
	import nest.modules.pipes.interfaces.IPipeMessage;
	import nest.patterns.mediator.Mediator;
	
	/**
	 * Junction Mediator.
	 * <P>
	 * A base class for handling the Pipe Junction in an IPipeAware 
	 * Core.</P>
	 */
	public class JunctionMediator extends Mediator
	{
		/**
		 * Accept input pipe notification name constant.
		 */ 
        public static const ACCEPT_INPUT_PIPE:String 	= 'acceptInputPipe';
		
		/**
		 * Accept output pipe notification name constant.
		 */ 
        public static const ACCEPT_OUTPUT_PIPE:String 	= 'acceptOutputPipe';

		/**
		 * Constructor.
		 */
		public function JunctionMediator( component:Junction )
		{
			super( component );
		}

		/**
		 * List Notification Interests.
		 * <P>
		 * Returns the notification interests for this base class.
		 * Override in subclass and call <code>super.listNotificationInterests</code>
		 * to get this list, then add any sublcass interests to 
		 * the array before returning.</P>
		 */
		override public function listNotificationInterests():Vector.<String>
		{
			return new <String>[ 
				JunctionMediator.ACCEPT_INPUT_PIPE, 
				JunctionMediator.ACCEPT_OUTPUT_PIPE
		   ];	
		}
		
		/**
		 * Handle Notification.
		 * <P>
		 * This provides the handling for common junction activities. It 
		 * accepts input and output pipes in response to <code>IPipeAware</code>
		 * interface calls.</P>
		 * <P>
		 * Override in subclass, and call <code>super.handleNotification</code>
		 * if none of the subclass-specific notification names are matched.</P>
		 */
		override public function handleNotification( note:INotification ):void
		{
			const connectionTeeName	: String = note.getType();
			const pipeToConnect		: IPipeFitting = note.getBody() as IPipeFitting;
			
			switch( note.getName() )
			{
				// accept an input pipe
				// register the pipe and if successful 
				// set this mediator as its listener
				case JunctionMediator.ACCEPT_INPUT_PIPE:
//					trace("\t\t : ACCEPT_INPUT_PIPE =", connectionTeeName);
					if(junction.hasInputPipe(connectionTeeName)) 
					{
						MergeInputPipeWithTee(pipeToConnect, connectionTeeName);
					} 
					else if(junction.registerPipe(connectionTeeName, Junction.INPUT, pipeToConnect))
					{
						junction.addPipeListener(connectionTeeName, this, handlePipeMessage);		
					}
					break;
				
				// accept an output pipe
				case JunctionMediator.ACCEPT_OUTPUT_PIPE:
//					trace("\t\t : ACCEPT_OUTPUT_PIPE =", connectionTeeName);
					if(junction.hasOutputPipe(connectionTeeName)) 
					{
						AddOutputChannelToTee(pipeToConnect, connectionTeeName);
					} else {
						junction.registerPipe( connectionTeeName, Junction.OUTPUT, pipeToConnect );
					}
					break;
			}
		}
		
		private function AddOutputChannelToTee(outputPipe:IPipeFitting, teeName:String):void
		{
			const teeForOutput:IPipeFitting = junction.retrievePipe(teeName) as IPipeFitting;
//			trace("\t\t : Connect =", teeForOutput.pipeName, outputPipe);
			teeForOutput.connect(outputPipe);
//			trace(teeName, "TEE COUNT:", TeeSplit(teeForOutput).outputsCount());
		}
		
		private function MergeInputPipeWithTee(inputPipe:IPipeFitting, teeName:String):void
		{
			const teeForInput : TeeMerge = junction.retrievePipe(teeName) as TeeMerge;
//			trace("\t\t : Connect =", teeForInput, inputPipe);
			teeForInput.connectInput(inputPipe);
//			trace(teeName, "CHAIN LENGTH:", teeForInput.chainLength);
		}
		
		/**
		 * Handle incoming pipe messages.
		 * <P>
		 * Override in subclass and handle messages appropriately for the module.</P>
		 */
		public function handlePipeMessage( message:IPipeMessage ):void
		{
		}
		
		/**
		 * The Junction for this Module.
		 */
		protected function get junction():Junction
		{
			return viewComponent as Junction;
		}
		
	
	}
}