/*
 PureMVC AS3/MultiCore Utility – Pipes
 Copyright (c) 2008 Cliff Hall<cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
 package nest.modules.pipes.interfaces
{
	/**
	 * Pipe Aware interface.
	 * <P>
	 * Can be implemented by any PureMVC Core that wishes
	 * to communicate with other Cores using the Pipes 
	 * utility.</P>
	 */
	public interface IPipeAware
	{
		function acceptInputPipe(name:String, pipe:IPipeFitting):void;
		function acceptOutputPipe(name:String, pipe:IPipeFitting):void;
	}
}