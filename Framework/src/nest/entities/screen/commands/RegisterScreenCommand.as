/**
 * ...
 * @author Vladimir Minkin
 */

package nest.entities.screen.commands
{
import nest.entities.screen.Screen;
import nest.entities.screen.ScreenCache;
import nest.entities.screen.ScreensProxy;
import nest.interfaces.ICommand;
import nest.patterns.command.SimpleCommand;

public final class RegisterScreenCommand extends SimpleCommand implements ICommand
{
	[Inject] public var screensProxy:ScreensProxy;

	override public function execute( screen:Object, mediatorName:String ):void
	{
		trace(" > Nest -> RegisterScreenCommand > execute: mediatorName =", mediatorName, screen);
		const screenCache:ScreenCache = new ScreenCache(Screen(screen), mediatorName);
		screensProxy.cacheScreenByName(Screen(screen).name, screenCache);
	}
}
}
