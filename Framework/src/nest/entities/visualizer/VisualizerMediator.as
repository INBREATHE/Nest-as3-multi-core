/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.visualizer
{
import nest.interfaces.INotification;
import nest.patterns.mediator.Mediator;
import nest.patterns.observer.NFunction;

public final class VisualizerMediator extends Mediator
{
	[Inject] public var proxy:VisualizerProxy;

	public function VisualizerMediator() {
		super(new Visualizer());
	}

	//==================================================================================================
	override public function listNotificationsFunctions():Vector.<NFunction> {
		//==================================================================================================
		return new <NFunction>[
			new NFunction( VisualizerNotification.SHOW,  ShowVisualizer )
		,	new NFunction( VisualizerNotification.HIDE,  HideVisualizer )
		];
	}

	//==================================================================================================
	override public function listNotificationInterests():Vector.<String> {
	//==================================================================================================
		return new <String>[
		];
	}

	//==================================================================================================
	override public function handleNotification( note:INotification ):void {
	//==================================================================================================
		var name:String = note.getName();
		var body:Object = note.getBody();
		switch (name) {

		}
		this.applyViewComponentMethod(name, body);
	}

	//==================================================================================================
	private function ShowVisualizer():void {
	//==================================================================================================

	}

	//==================================================================================================
	private function HideVisualizer():void {
	//==================================================================================================

	}

	//==================================================================================================
	override public function onRegister():void {
	//==================================================================================================

	}

	//==================================================================================================
	override public function onRemove():void {
	//==================================================================================================

	}

	private function get visualizer():Visualizer { return Visualizer(viewComponent); }
}
}