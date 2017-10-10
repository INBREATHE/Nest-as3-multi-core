package nest.entities.elements.transitions
{
	import nest.entities.application.Application;
	import nest.entities.screen.Screen;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;

	public class FadeTransition extends Transition implements ITransition
	{
		private static const 
			SCREEN_FADE_TIME	:Number = 0.25125
		,	SCREEN_FADE_EASE	:String = Transitions.EASE_IN;
		
		private var
			_cover			: Quad
		,	_fadeOutTween	: Tween
		,	_fadeInTween	: Tween
		;
		
		public override function get isShowPossible():Boolean {
			return _cover.parent == null;
		}
		
		public function FadeTransition()
		{
			SetupCover();
			SetupTransitions();
		}
		
		override public function hide(screen:Screen, isReturn:Boolean):void
		{
			_cover.alpha = 0;
			_fadeInTween.onCompleteArgs	= [screen];
			Starling.current.stage.addChild(_cover);
			Starling.juggler.add(_fadeInTween);
		}
		
		override public function show(screen:Screen, isReturn:Boolean):void
		{
			_fadeOutTween.onCompleteArgs = [screen];
			_fadeOutTween.onStartArgs = [screen];
			if(!_fadeInTween.isComplete) _fadeInTween.nextTween = _fadeOutTween;
			else Starling.juggler.add(_fadeOutTween);
		}
		
		//==================================================================================================
		private function SetupCover():void {
		//==================================================================================================
			_cover = new Quad(
				Application.SCREEN_WIDTH, 
				Application.SCREEN_HEIGHT, 
				0x000000
			);
			_cover.touchable = false;
		}
		
		//==================================================================================================
		private function SetupTransitions():void {
		//==================================================================================================
			if(_fadeInTween!=null) _fadeInTween = null;
			if(_fadeOutTween!=null) _fadeOutTween = null;
				
			_fadeInTween = new Tween(_cover, SCREEN_FADE_TIME, SCREEN_FADE_EASE);
			_fadeOutTween = new Tween(_cover, SCREEN_FADE_TIME, SCREEN_FADE_EASE);
			
			_fadeInTween.fadeTo(1);
			_fadeOutTween.fadeTo(0);
			
			_fadeInTween.onComplete 	= TweenHandler_RemoveCurrentScreenFromStage;
			_fadeOutTween.onStart 		= TweenHandler_AddCurrentScreenToStage;
			_fadeOutTween.onComplete 	= TweenHandler_ChangeScreenComplete;
		}
		
		//==================================================================================================
		private function TweenHandler_ChangeScreenComplete(newScreen:Screen):void {
		//==================================================================================================
			if (_cover.parent) _cover.removeFromParent();
			Starling.juggler.removeTweens(_cover);

			if(onShowComplete) onShowComplete(newScreen);
			SetupTransitions();
		}
		
		//==================================================================================================
		private function TweenHandler_AddCurrentScreenToStage(newScreen:Screen):void {
		//==================================================================================================
			if(onShowStart) onShowStart(newScreen);
		}
		
		//==================================================================================================
		private function TweenHandler_RemoveCurrentScreenFromStage(prevScreen:Screen):void {
		//==================================================================================================
			if(onHideComplete) onHideComplete(prevScreen);
		}
	}
}