package nest.entities.visualizer.commands
{
	import nest.entities.visualizer.VisualizerMediator;
	import nest.entities.visualizer.VisualizerProxy;
	import nest.patterns.command.SimpleCommand;
	
	public final class RegisterVisualizerCommand extends SimpleCommand
	{
		override public function execute( body:Object, type:String ) : void
		{
			var visualizerMediator : VisualizerMediator = new VisualizerMediator();
			
			this.facade.registerProxy( VisualizerProxy );
			this.facade.registerMediatorAdvance( visualizerMediator );
		}
	}
}