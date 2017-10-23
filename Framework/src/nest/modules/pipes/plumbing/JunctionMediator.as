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
		override protected function listNotificationInterests():Vector.<String>
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
			const connectionChannel	: String = note.getType();
			const pipeToConnect		: IPipeFitting = note.getBody() as IPipeFitting;
			
			trace("\n> Nest -> JunctionMediator:", this, connectionChannel, pipeToConnect);
			
			switch( note.getName() )
			{
				// accept an input pipe
				// register the pipe and if successful 
				// set this mediator as its listener
				case JunctionMediator.ACCEPT_INPUT_PIPE:
					trace("\t\t : ACCEPT_INPUT_PIPE channel:", connectionChannel);
					trace("\t\t : hasInputPipe =", junction.hasInputPipe(connectionChannel));
					if(junction.hasInputPipe(connectionChannel))
					{
						MergePipeToInputChannel(pipeToConnect, connectionChannel);
					} 
					else if(junction.registerPipe(connectionChannel, Junction.INPUT, pipeToConnect))
					{
						junction.addPipeListener(connectionChannel, this, handlePipeMessage);
					}
					break;
				
				// accept an output pipe
				case JunctionMediator.ACCEPT_OUTPUT_PIPE:
					trace("\t\t : ACCEPT_OUTPUT_PIPE channel =", connectionChannel);
					trace("\t\t : hasInputPipe =", junction.hasOutputPipe(connectionChannel));
					if(junction.hasOutputPipe(connectionChannel))
					{
						AddPipeToOutputChannel(pipeToConnect, connectionChannel);
					}
					else
					{
						junction.registerPipe( connectionChannel, Junction.OUTPUT, pipeToConnect );
					}
					break;
			}
		}
		
		private function AddPipeToOutputChannel(outputPipe:IPipeFitting, channelName:String):void
		{
			const outputChannelPipe:IPipeFitting = junction.retrievePipe(channelName) as IPipeFitting;
			trace("\t\t : AddPipeToOutputChannel -> Connect =", outputChannelPipe, outputPipe);
			if(outputChannelPipe) {
				outputChannelPipe.connect(outputPipe);
				trace("\t\t :", "PIPES COUNT:", SplitPipe(outputChannelPipe).outputsCount());
			}
		}
		
		private function MergePipeToInputChannel(inputPipe:IPipeFitting, channelName:String):void
		{
			const pipeForInput : MergePipe = junction.retrievePipe(channelName) as MergePipe;
			trace("\t\t : MergeInputPipeWithTee -> Connect =", pipeForInput, inputPipe);
			if(pipeForInput) {
				pipeForInput.connectInput(inputPipe);
				trace("\t\t :", "CHAIN LENGTH:", pipeForInput.chainLength);
			}

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