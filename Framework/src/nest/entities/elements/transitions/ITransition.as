package nest.entities.elements.transitions
{
	import nest.entities.screen.Screen;

	public interface ITransition
	{
		function get isShowPossible():Boolean;
		function get isHidePossible():Boolean;
		function hide(screen:Screen, isReturn:Boolean):void;
		function show(screen:Screen, isReturn:Boolean):void;
	}
}