/**
 * ...
 * @author Vladimir Minkin
 */

package nest.entities.screen.commands
{
	import nest.entities.screen.ScreenCache;
	import nest.entities.screen.ScreenMediator;
	import nest.entities.screen.ScreensProxy;
	import nest.interfaces.ICommand;
	import nest.patterns.command.SimpleCommand;

	public class RemoveScreenCommand extends SimpleCommand implements ICommand
	{
		[Inject] public var screensProxy:ScreensProxy;
		
		override public function execute( screenData:Object, screenName:String ):void 
		{
			var screenCache		: ScreenCache = screensProxy.getCacheByScreenName(screenName);
			var screenMediator	: ScreenMediator = facade.retrieveMediator(screenCache.mediatorName) as ScreenMediator;

//			screensProxy.currentScreen = screenCache;
//			this.send( ApplicationNotification.HIDE_SCREEN );
//			screenMediator.onPrepare(screenData);
		}
	}
}
