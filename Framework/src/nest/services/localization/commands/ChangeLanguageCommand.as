package nest.services.localization.commands
{
	import nest.entities.application.ApplicationNotification;
	import nest.patterns.command.SimpleCommand;
	
	public final class ChangeLanguageCommand extends SimpleCommand
	{
		override public function execute( body:Object, type:String ):void
		{
			trace("\n> Nest -> ChangeLanguageCommand:", body);
			this.facade.currentLanguage = String(body);
			this.send( ApplicationNotification.LANGUAGE_CHANGED );
		}
	}
}