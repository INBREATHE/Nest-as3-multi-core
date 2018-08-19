package nest.entities.elements.transitions
{
	import nest.entities.application.Application;
	import nest.entities.screen.Screen;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;

	public class SlideTransition extends Transition implements ITransition
	{
		private static const 
			SCALE_DOWN_VALUE	:Number = 0.9
		,	SCALE_DOWN_TIME		:Number = 0.7
		,	SCALE_DOWN_EASE		:String = Transitions.EASE_OUT
		
		,	SLIDE_OVER_TIME		:Number = 0.5
		,	SLIDE_OVER_DELAY	:Number = 0.2
		,	SLIDE_OVER_EASE		:String = Transitions.EASE_OUT
		;
		
		private var
			_cover			    : Quad
		,	_prevScreen		  : Screen
		,	_slideOverTween : Tween
		,	_scaleDownTween : Tween
		;
		
		private const
			_scaleOffsetPos	: Number = ( 1 - SCALE_DOWN_VALUE ) * 0.5
		,	_scaleOffsetX 	: Number = Application.SCREEN_WIDTH * _scaleOffsetPos
		,	_scaleOffsetY 	: Number = Application.SCREEN_HEIGHT * _scaleOffsetPos
		;
		
		public function SlideTransition()
		{
			SetupCover();
		}
		
		public override function get isShowPossible():Boolean {
			return _cover.parent == null;
		}
		
		public override function get isHidePossible():Boolean {
			return false;
		}
		
		override public function hide( screen:Screen, isReturn:Boolean ):void
		{
			_prevScreen = screen;
			
			_scaleDownTween = new Tween( screen, SCALE_DOWN_TIME, SCALE_DOWN_EASE );
			_scaleDownTween.scaleTo( SCALE_DOWN_VALUE );
			_scaleDownTween.moveTo( _scaleOffsetX, _scaleOffsetY );
			
			screen.parent.addChild( _cover );
			Starling.juggler.add( _scaleDownTween );
		}
		
		override public function show( screen:Screen, isReturn:Boolean ):void
		{
			screen.x = Application.SCREEN_WIDTH * ( isReturn ? -1 : 1 );
			
			_slideOverTween = new Tween( screen, SLIDE_OVER_TIME, SLIDE_OVER_EASE );
			_slideOverTween.moveTo( 0, 0 );
			_slideOverTween.delay = SLIDE_OVER_DELAY;
			
			_slideOverTween.onStart = TweenHandler_AddCurrentScreenToStage;
			_slideOverTween.onComplete = TweenHandler_ChangeScreenComplete;
			
//			if(_scaleDownTween.isComplete)
			Starling.juggler.add( _slideOverTween );
//			else _scaleDownTween.nextTween = _slideOverTween;
		}
		
		//==================================================================================================
		private function TweenHandler_ChangeScreenComplete():void {
		//==================================================================================================
			_cover.removeFromParent();						
			if( onHideComplete && _prevScreen ) onHideComplete( _prevScreen );
			if( onShowComplete ) onShowComplete( _slideOverTween.target );
			_slideOverTween = null;
			_scaleDownTween = null;
			_prevScreen.y = 0;
			_prevScreen.scaleX = 1;
			_prevScreen.scaleY = 1;
		}
		
		//==================================================================================================
		private function TweenHandler_AddCurrentScreenToStage():void {
		//==================================================================================================
			if( onShowStart ) onShowStart( _slideOverTween.target );
		}
		
		//==================================================================================================
		private function SetupCover():void {
		//==================================================================================================
			_cover = new Quad(
				Application.SCREEN_WIDTH, 
				Application.SCREEN_HEIGHT, 
				0x000000
			);
			_cover.alpha = 0.6;
			_cover.touchable = false;
		}
	}
}