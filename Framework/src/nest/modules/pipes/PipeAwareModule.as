package nest.modules.pipes
{
import flash.display.Sprite;

import nest.interfaces.IFacade;
import nest.modules.pipes.interfaces.IPipeAware;
import nest.modules.pipes.interfaces.IPipeFitting;
import nest.patterns.observer.Notification;

public class PipeAwareModule extends Sprite implements IPipeAware
{
	/**
	 * Standard output pipe name constant.
	 */
	public static const STD_OUT:String 				= 'outputFromShellToAll';

	/**
	 * Standard input pipe name constant.
	 */
	public static const STD_IN:String 				= 'inputToMain';

	/**
	 * Constructor.
	 * <P>
	 * In subclass, create appropriate facade and pass
	 * to super.</P>
	 */
	public function PipeAwareModule( facade:IFacade )
	{
		super();
		this.facade = facade;
	}

	/**
	 * Accept an input pipe.
	 * <P>
	 * Registers an input pipe with this module's Junction.
	 */
	public function acceptInputPipe( name:String, pipe:IPipeFitting ):void
	{
		facade.sendNotification( new Notification(JunctionMediator.ACCEPT_INPUT_PIPE, pipe, name ));
	}

	/**
	 * Accept an output pipe.
	 * <P>
	 * Registers an input pipe with this module's Junction.
	 */
	public function acceptOutputPipe( name:String, pipe:IPipeFitting ):void
	{
		facade.sendNotification( new Notification(JunctionMediator.ACCEPT_OUTPUT_PIPE, pipe, name ));
	}

	protected var facade:IFacade;
}
}