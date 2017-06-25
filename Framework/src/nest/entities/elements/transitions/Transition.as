package nest.entities.elements.transitions
{
	import nest.entities.screen.Screen;

	public class Transition implements ITransition
	{
		public var 
			onShowStart		: Function
		,	onShowComplete	: Function
		,	onHideComplete	: Function
		;
		
		public function Transition()
		{
			
		}
		
		public function get isHidePossible():Boolean {
			return false;
		}
		
		public function get isShowPossible():Boolean {
			return true;
		}
		
		//==================================================================================================
		public function hide(screen:Screen, isReturn:Boolean):void { }
		public function show(screen:Screen, isReturn:Boolean):void { }
		//==================================================================================================
	
		
	}
}