/**
 * ...
 * @author Vladimir Minkin
 */
package nest.entities.screen.commands
{
import nest.entities.application.ApplicationNotification;
import nest.entities.popup.PopupNotification;
import nest.entities.screen.Screen;
import nest.entities.screen.ScreenCache;
import nest.entities.screen.ScreenData;
import nest.entities.screen.ScreenMediator;
import nest.entities.screen.ScreensProxy;
import nest.interfaces.ICommand;
import nest.patterns.command.SimpleCommand;

import starling.events.Event;

public class ChangeScreenCommand extends SimpleCommand implements ICommand
{
	[Inject] public var screensProxy:ScreensProxy;

	override public function execute( body:Object, nextScreenName:String ):void
	{
		const currentScreen 	  : ScreenCache 		= screensProxy.currentScreen;
		const currentScreenName	: String 			    = currentScreen ? currentScreen.name : null;
		const goPrevious		    : Boolean			    = nextScreenName == Screen.PREVIOUS || ( currentScreen && currentScreen.prevScreenCache && currentScreen.prevScreenCache.name == nextScreenName );
		const targetScreen		  : ScreenCache 		= (goPrevious ? currentScreen.prevScreenCache : screensProxy.getCacheByScreenName(nextScreenName)) || screensProxy.getFirstCachedScreen();
		const screenMediator	  : ScreenMediator 	= facade.getMediator( targetScreen.mediatorName ) as ScreenMediator;

		if ( currentScreen ) {
			if ( !goPrevious && targetScreen.prevScreenCache == null )	targetScreen.prevScreenCache = currentScreen;
			else currentScreen.prevScreenCache = null;

			ScreenMediator( facade.getMediator( currentScreen.mediatorName )).onLeave();

			this.send( ApplicationNotification.HIDE_SCREEN, currentScreen.screen, nextScreenName );
		}

		const screenData:ScreenData = ( body != null && body is ScreenData ) ? ScreenData( body ) : new ScreenData();

		screensProxy.currentScreen = targetScreen;
		screenData.previous = goPrevious;
		screenData.fromScreen = currentScreenName;
		screenData.toScreen = targetScreen.name;

		trace("> Nest -> ChangeScreenCommand nextScreenName:", nextScreenName);
		trace("> Nest -> ChangeScreenCommand goPrevious:", goPrevious);
		trace("> Nest -> ChangeScreenCommand screenData:", JSON.stringify(screenData));

		if ( currentScreen && currentScreen.screen )
			currentScreen.screen.addEventListener( Event.REMOVED_FROM_STAGE, function ():void
			{
				currentScreen.screen.removeEventListeners( Event.REMOVED_FROM_STAGE );
				send( PopupNotification.HIDE_ALL_POPUPS );
				screenMediator.prepareDataForScreen( screenData );
			});
		else screenMediator.prepareDataForScreen( screenData );
	}
}
}
