/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.scroller
{
import flash.geom.Point;
import flash.utils.getTimer;

import nest.Environment;
import nest.entities.application.Application;
import nest.entities.screen.ScrollScreen;
import nest.interfaces.IScrollItem;

import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class Scroller
{
	private const

		MOVE_FRICTION		:Number 	= 0.8
	,	SCALE_TIME			:Number 	= 0.15
	,	HOLD_START_DELAY:Number 	= 0.3
	,	HOLD_END_DELAY	:Number 	= 0.2
	,	SCALE_TO			  :Number 	= 1.050
	,	ALPHA_LEFT			:Number 	= 0.10
	,	ALPHA_RIGHT			:Number 	= 1 + ALPHA_LEFT
	,	SCROLL_SPEED		:Number 	= 0.0015
	,	SWIPE_SPEED			:Number 	= 1.5
	;

	private var
		__limitXMin			  :int 		= int.MAX_VALUE
	,	__limitXMax			  :int 		= int.MIN_VALUE

	,	__itemSize			  :uint 		= uint.MIN_VALUE
	,	__itemSizeDouble	:uint 		= uint.MIN_VALUE
	,	__itemSizeHalf		:uint 		= uint.MIN_VALUE
	,	__itemSizeQuater	:uint 		= uint.MIN_VALUE

	,	__limitTapMin		  :uint 		= uint.MIN_VALUE
	,	__limitTapMax		  :uint 		= uint.MIN_VALUE

	,	__childNum			  :uint 		= uint.MIN_VALUE

	,	_fadeFromCenter		:Boolean 	= false
	,	_doHoldAction		  :Boolean 	= false
	,	_doHoldScale		  :Boolean 	= false
	,	_needTouchPoint		:Boolean 	= false
	,	_hideInvisible		:Boolean 	= false

	,	_isScrollPossible	:Boolean	= false
	,	_isTapPossible		:Boolean 	= false
	,	_isFindCurrent		:Boolean 	= false
	,	_isHoldSelected		:Boolean 	= false
	,	_isHoldStart		  :Boolean 	= false
	,	_isHoldComplete		:Boolean 	= false

	,	_tweenScale			:Tween
	,	_tweenMove			:Tween

	,	_touchStartCallback	:Function
	,	_touchMoveCallback	:Function
	,	_touchEndCallback	  :Function
	,	_holdStartCallback	:Function
	,	_holdEndCallback	  :Function

	,	_touch				  :Touch

	,	_movement			  :Point
	,	_target				  :DisplayObject
	,	_currentTarget		:Sprite

	,	_startTime			:Number 	= Number.MAX_VALUE
	,	_startPosX			:Number 	= Number.MAX_VALUE
	,	_startTouchX		:Number 	= Number.MAX_VALUE
	,	_startTouchY		:Number 	= Number.MAX_VALUE

	,	_endTime			  :Number 	= Number.MAX_VALUE

	,	_posX				        :int 		= int.MAX_VALUE
	,	_targetPos			    :int 		= int.MAX_VALUE
	,	_currentTargetIndex	:int 		= int.MAX_VALUE
	,	_targetPropScreen	  :Number = Number.MAX_VALUE
	,	_targetAlpha		    :Number = Number.MAX_VALUE

	,	_deltaPosX			:int 		= int.MAX_VALUE
	,	_deltaPosXAbs		:uint 	= uint.MAX_VALUE
	,	_deltaTouchX		:int 		= int.MAX_VALUE
	,	_deltaTime			:uint 	= uint.MAX_VALUE
	,	_deltaSign			:int 		= int.MAX_VALUE

	,	_speed				  :Number = Number.MAX_VALUE
	,	_offset				  :Number = Number.MAX_VALUE

	,	_counter			  :int 		= int.MAX_VALUE

	,	_container			:ScrollContainer
	
	,	areaWidth			  :uint	 	= 0
	,	areaHeight			:uint	 	= 0
	,	areaWidthHalf		:Number = 0
	,	areaHeightHalf	:Number = 0
	
	,	TOUCH_ACCURACY		:int 		= 20
	;

	private var _env:Environment;
		
	public function Scroller() 
	{
		_env = Application.ENVIRONMENT;
		this.areaWidth = _env.viewportSize.x;
		this.areaHeight = _env.viewportSize.y;
		
		TOUCH_ACCURACY *= _env.scaleFactor.x;
		
		areaWidthHalf = areaWidth * 0.5;
		areaHeightHalf = areaHeight * 0.5;
	}

	public function reset():void
	{
		if (_tweenScale && !_tweenScale.isComplete) Starling.juggler.remove(_tweenScale);
		if (_tweenMove && !_tweenMove.isComplete) Starling.juggler.remove(_tweenMove);
		if (_currentTarget) _currentTarget.scaleX = _currentTarget.scaleY = 1;

		Starling.juggler.removeTweens(_container);

		if(_isScrollPossible) _container.removeEventListener(TouchEvent.TOUCH, Handle_HorizontalScroll);
		else _container.removeEventListener(TouchEvent.TOUCH, Handle_TouchOnly);

		_container = null;
	}

	public function setup(container:Object):void
	{
		_container      = ScrollContainer(container);

		_posX 				  = _container.current;

		__limitXMin 		= _container.minimum;
		__limitXMax 		= _container.maximum;

		__itemSize 			  = _container.itemsize;
		__itemSizeDouble 	= __itemSize * 2;
		__itemSizeHalf 		= __itemSize * 0.50;
		__itemSizeQuater 	= __itemSize * 0.250;

		_fadeFromCenter 	= _container.fadeFromCenter;
		_doHoldAction 		= _container.doHoldAction;
		_needTouchPoint		= _container.needTouchPoint;
		_hideInvisible		= _container.hideInvisible;

		_holdStartCallback  = _container.holdStartFunction;
		_holdEndCallback    = _container.holdEndFunction;

		__limitTapMin = areaWidthHalf - __itemSizeHalf;
		__limitTapMax = areaWidthHalf + __itemSizeHalf;

		__childNum = _container.numChildren;

		_isHoldStart = false;
		_isScrollPossible = __childNum > 2; // Two because of background

		_touchStartCallback = _container.startFunction;
		_touchMoveCallback = _container.moveFunction;
		_touchEndCallback = _container.endFunction;

//		trace("> Scroller > _isScrollPossible: " + _isScrollPossible);

		if(_isScrollPossible){
			if(_container.type == ScrollerType.HORIZONTAL)
				_container.addEventListener(TouchEvent.TOUCH, Handle_HorizontalScroll)
		} else {
			_container.addEventListener(TouchEvent.TOUCH, Handle_TouchOnly)
		}

		MoveUpdate();
	}

	private function Handle_TouchOnly(e:TouchEvent):void
	{
		e.stopPropagation();
		_touch = Touch(e.getTouch(_container, TouchPhase.ENDED));
		if (_touch)
		{
			_target = _touch.target;
			_isTapPossible = _target is IScrollItem && ScrollScreen(_target.parent.parent).checkIfTouchPossible(IScrollItem(_target)) == true;
			MoveComplete();
		}
	}

	//==================================================================================================
	private function Handle_HorizontalScroll(e:TouchEvent):void {
	//==================================================================================================
		e.stopPropagation();
		_touch = Touch(e.getTouch(_container));
		if (_touch)
		{
			if(_touch.phase != TouchPhase.HOVER)
			switch (_touch.phase)
			{
				case TouchPhase.BEGAN:
					if(_tweenMove) Starling.juggler.remove(_tweenMove);

					_posX 			= _container.x; 	// Текущее положение скроллера
					_target 		= _touch.target; 	// Объект на который нажали
					_startTime 		= getTimer(); 		// время надатия, нужно для определения скорости
					_startPosX 		= _posX;
					_startTouchX 	= _touch.globalX;
					_startTouchY 	= _touch.globalY;

					// Определяем не вышли ли мы за пределы области тача
					_isTapPossible = ( _startTouchX > __limitTapMin && _startTouchX < __limitTapMax );
//						trace("Touch Begin - _isTapPossible 1: " + _isTapPossible, _target, _target is IScrollItem);
					_isTapPossible = _target is IScrollItem && ScrollScreen(_target.parent.parent).checkIfTouchPossible(IScrollItem(_target)) == true;
//						trace("Touch Begin - _isTapPossible 2: " + _isTapPossible);

					// Нужно точно определить что мы попали в элемент скроллера и что переход возможен (только после окончания анимации, и инициализации экрана)
					if (!_isTapPossible) return;
					if (_doHoldAction && _target is Sprite && _isTapPossible) {
						_isHoldSelected 	= true;
						_isHoldStart 		= false;
						_currentTarget 		= _target as Sprite;

						_tweenScale 		= new Tween(_currentTarget, SCALE_TIME);
						_tweenScale.delay 	= HOLD_START_DELAY;
						_tweenScale.onStart = HoldStart;
						_tweenScale.onComplete = HoldComplete;
						if(_doHoldScale) _tweenScale.scaleTo(SCALE_TO);
						Starling.juggler.add(_tweenScale);
					}

					if (_touchStartCallback) _touchStartCallback(_target);

					break;
				case TouchPhase.MOVED:
					_movement = _touch.getMovement(_container);
					_posX += _movement.x * MOVE_FRICTION;

					if(_isTapPossible) {
						_deltaTouchX = _startTouchX - _touch.globalX;
						_isTapPossible = Math.abs(_deltaTouchX) < TOUCH_ACCURACY;
					}

					if (!_isTapPossible && _isHoldSelected) {
						_isHoldSelected = false;
						Starling.juggler.remove(_tweenScale);
						if(_doHoldScale) {
							_tweenScale = new Tween(_currentTarget, SCALE_TIME);
							_tweenScale.delay = HOLD_END_DELAY;
							_tweenScale.scaleTo(1);
							Starling.juggler.add(_tweenScale);
						}
						if(_isHoldComplete) HoldEnd();
					}
					_container.x = _posX;

					MoveUpdate();

					break;
				case TouchPhase.ENDED:

					if (_isHoldSelected) {
						if(_tweenScale) Starling.juggler.remove(_tweenScale);
						_isHoldSelected = false;
						if (_isHoldStart) {
							_isHoldStart = false;
							_isTapPossible = false;
							if(_doHoldScale) {
								_tweenScale = new Tween(_currentTarget, SCALE_TIME);
								_tweenScale.delay = HOLD_END_DELAY;
								_tweenScale.scaleTo(1);
								Starling.juggler.add(_tweenScale);
							}
							if(_isHoldComplete) HoldEnd();
						}
					}

					_endTime 		  = getTimer();
					_deltaTime 		= _endTime - _startTime;
					_deltaPosX 		= _startPosX - _posX;
					_deltaPosXAbs = Math.abs(_deltaPosX);
					_deltaSign 		= _deltaPosX > 0 ? -1 :  1;
					_speed 			  = _deltaPosXAbs / _deltaTime;

//						if(_currentTargetIndex == 0 && _deltaPosX < 0) {
//							_posX = __limitXMin; // Если мы двигаем вправо первый элемент
//						} else {
					_posX = __limitXMin;
					if (_deltaPosXAbs > 0 && _deltaPosXAbs < __itemSizeHalf && _speed > SWIPE_SPEED) {
						_offset = (_currentTargetIndex - _deltaSign) * __itemSize;
						if (_deltaPosXAbs < __itemSizeHalf) _deltaPosXAbs = __itemSizeHalf;
					} else {
						_offset = _currentTargetIndex  * __itemSize;
					}

					_posX -= _offset;

					// Ограничения
					if (_posX <= __limitXMax) _posX = __limitXMax;
					else if ( _posX >= __limitXMin) _posX = __limitXMin;

					// Смотрим находится ли элемент на который кликнули в области активности
					if(_isTapPossible) {
						_targetPos = _touch.globalX;
						_isTapPossible = (_targetPos > __limitTapMin && _targetPos < __limitTapMax);
					}
//						}
//						trace("_posX = " + _posX);
//						trace("_offset = " + _offset);
//						trace("_targetPos = " + _targetPos);
//						trace("_deltaPosXAbs : " + _deltaPosXAbs);
//						trace("_isTapPossible = " + _isTapPossible);
//						trace("_currentTargetIndex = " + _currentTargetIndex);

				if(_isTapPossible == false && _deltaPosXAbs > 0) {
					_tweenMove = new Tween(_container, _deltaPosXAbs * SCROLL_SPEED / _env.scaleFactor.x, Transitions.EASE_OUT);
					_tweenMove.onUpdate = MoveUpdate;
					_tweenMove.onComplete = MoveComplete;
					_tweenMove.animate("x", _posX);
					Starling.juggler.add(_tweenMove);
				} else {
					_container.x = _posX;
					MoveComplete();
				}
				break;
			}
		}
	}
	//==================================================================================================
	private function HideInvisible():void {
	//==================================================================================================
		_counter = 0;
//		var visible = 0;
		var leftEdge:int;
		while (++_counter < __childNum) {
			_target = _container.getChildAt(_counter);
			leftEdge = -_target.width;
			_targetPos = _target.x + _posX;
			_target.visible = _targetPos > leftEdge && _targetPos < areaWidth;
//			if(_target.visible) visible++;
		}
//		trace("> Scroller -> visible: " + visible + "/" + __childNum);
	}

	//==================================================================================================
	private function FadeFromCenter():void {
	//==================================================================================================
		_counter = 0;
		_isFindCurrent = false;
		while (++_counter < __childNum) {
			_target 	  = _container.getChildAt(_counter);
			_targetPos 	= _target.x + _posX;

			if (!_isFindCurrent && _targetPos > __limitTapMin && _targetPos < __limitTapMax) {
				_currentTargetIndex = _counter - 1;
				_isFindCurrent = true;
			}

			if ( _targetPos < areaWidthHalf ) {
				_targetPropScreen = _targetPos / areaWidthHalf;
				_targetAlpha = Math.min(1, ALPHA_LEFT + _targetPropScreen);
			} else {
				_targetPos -= areaWidthHalf;
				_targetPropScreen = _targetPos / areaWidthHalf;
				_targetAlpha = Math.min(1, ALPHA_RIGHT - _targetPropScreen);
			}

			_target.visible = (_targetAlpha >= 0);
			if (_target.visible){
				_target.alpha = _targetAlpha;
			}
		}
	}

	//==================================================================================================
	private function HoldStart():void {
	//==================================================================================================
		_isHoldStart = true;
	}

	//==================================================================================================
	private function HoldComplete():void {
	//==================================================================================================
//			trace("> Nest -> Scroller - HoldComplete");
		_isHoldComplete = true;
		if (_holdStartCallback) _holdStartCallback(_currentTarget, new Point(_startTouchX, _startTouchY));
	}

	//==================================================================================================
	private function HoldEnd():void {
	//==================================================================================================
//			trace("> Nest -> Scroller - HoldEnd");
		_isHoldComplete = false;
		if (_holdEndCallback) _holdEndCallback();
	}

	//==================================================================================================
	private function MoveUpdate():void {
	//==================================================================================================
		if (_fadeFromCenter) FadeFromCenter();
		else _currentTargetIndex = getCurrentIndex();

		if(_hideInvisible) HideInvisible();

		if (_touchMoveCallback) _touchMoveCallback(_currentTargetIndex);
		_container.itemid = _currentTargetIndex;
	}

	//==================================================================================================
	private function getCurrentIndex():uint {
	//==================================================================================================
		var result:uint = 0;
		if(_posX < __limitXMin) { // Только если мы двигаем скроллер влево
			if(_posX > __limitXMax) // Только если у нас не последний элемент
			result = Math.round(Math.abs(_posX - __limitXMin) / __itemSize)
			else result = __childNum - 2;
		}
		return result;
	}

	//==================================================================================================
	private function MoveComplete():void {
	//==================================================================================================
		MoveUpdate();
		trace("MoveComplete", _isTapPossible,  _touchEndCallback != null);
		if (_isTapPossible && _touchEndCallback) {
			if (_needTouchPoint) _touchEndCallback(_currentTargetIndex, new Point(_touch.globalX, _touch.globalY));
			else _touchEndCallback(_currentTargetIndex);
		}
	}
}
}