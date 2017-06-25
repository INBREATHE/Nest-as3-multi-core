package nest.modules.pipes.plumbing
{
	import nest.modules.pipes.interfaces.IPipeFitting;
	
	/** 
	 * Merging Pipe Tee.
	 * <P>
	 * Writes the messages from multiple input pipelines into
	 * a single output pipe fitting.</P>
	 */
	public class TeeMerge extends Pipe
	{
		
		/**
		 * Constructor.
		 * <P>
		 * Create the TeeMerge.
		 * This is the most common configuration, though you can connect
		 * as many inputs as necessary by calling <code>connectInput</code>
		 * repeatedly.</P>
		 * <P>
		 * Connect the single output fitting normally by calling the 
		 * <code>connect</code> method, as you would with any other IPipeFitting.</P>
		 */
		public function TeeMerge() 
		{
			super(Pipe.newChannelID());
		}
		
		public function merge(input1:IPipeFitting, input2:IPipeFitting):void 
		{
			connectInput(input1);
			connectInput(input2);
		}

		/** 
		 * Connect an input IPipeFitting.
		 * <P>
		 * NOTE: You can connect as many inputs as you want
		 * by calling this method repeatedly.</P>
		 * 
		 * @param input the IPipeFitting to connect for input.
		 */
		public function connectInput( input:IPipeFitting ):Boolean
		{
			return input.connect(this);
		}
	}
}