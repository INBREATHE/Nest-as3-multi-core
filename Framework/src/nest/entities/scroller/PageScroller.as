/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.scroller
{
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getTimer;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class PageScroller
{
	private static const SCROLL_SPEED :Number = 0.0015;

	private var __counterColor:uint;
	private var __counterAColor:uint;

	private const _pages:Vector.<DisplayObject> = new Vector.<DisplayObject>();
	private const _content:Sprite = new Sprite();
	private const _counters:Sprite = new Sprite();

	private var _indexies:uint = 0;
	private var _pageindex:uint = 0;

	private var _counterQuad:Quad;
	private var _countersize:uint;
	private var _counteroffset:uint;

	private var _speed:Number = 0;
	private var _offset:uint = 0;

	private var _pagewidth:uint;
	private var _itemwidth:uint;
	private var _itemwidthhalf:uint;
	private var _deltawidth:uint;
	private var _viewport:Rectangle;
	private var _movement:Point;
	private var _position:int;
	private var _positionAbs:uint;
	private var _posStart:int;
	private var _posSign:int;
	private var _posDelta:int;
	private var _posDeltaAbs:int;
	private var _tween:Tween;
	private var _timeStart:uint;
	private var _timeDelta:uint;
	private var _timeEnd:uint;

	public function PageScroller(
		stage			: Sprite
	, 	pagewidth		: uint
	, 	viewport		: Rectangle
	, 	countersize		: uint = 0
	, 	counteroffset	: uint = 10
	,	countercolor	: uint = 0x222222
	,	counteracolor	: uint = 0x555555
	)
	{
		_pagewidth = pagewidth;
		_itemwidth = _pagewidth;
		_itemwidthhalf = _itemwidth * 0.5;
		_deltawidth = 0;
		_viewport = viewport;
		_countersize = countersize;
		_counteroffset = _countersize + counteroffset;

		__counterColor = countercolor;
		__counterAColor = counteracolor;

		stage.addChild(_content);
		stage.addChild(_counters);
	}

	public function addPage(value:DisplayObject):void
	{
		value.x = _indexies * _pagewidth;
		if (_pagewidth > value.width) value.x += (_pagewidth - value.width) * 0.5;

		_pages.push(value);
		_content.addChild(value);
		if(_countersize > 0) {
			_counterQuad = new Quad(_countersize, _countersize, __counterColor);
			_counterQuad.x = _indexies * _counteroffset;
			_counterQuad.touchable = false;
			_counters.addChild(_counterQuad);
			_counters.x = (_viewport.width - _counters.width) * 0.50;
		}
		_indexies += 1;
	}

	public function set viewport(value:Rectangle):void
	{
		_offset = (value.width - _pagewidth) * 0.5;
		_viewport = value;
		_content.x = value.x + _offset;
	}

	public function set y(value:uint):void
	{
		_content.y = value;
		_counters.y = value + _viewport.height + 20;
	}

	//==================================================================================================
	public function set itemwidth(value:uint):void {
	//==================================================================================================
		_itemwidth = value;
		_itemwidthhalf = _itemwidth * 0.5;
		_deltawidth = _pagewidth - _itemwidth;
	}

	public function start():void
	{
		_counterQuad = _counters.getChildAt(0) as Quad;
		_counterQuad.color = __counterAColor;
		_content.addEventListener(TouchEvent.TOUCH, onTouch);
	}

	//==================================================================================================
	private function onTouch(e:TouchEvent):void {
	//==================================================================================================
		var touch:Touch = e.getTouch(_content);
		if (touch == null) return;
		if (touch.phase == TouchPhase.BEGAN)
		{
			_position = _content.x;
			_posStart = _position;
			_timeStart = getTimer();
			Starling.juggler.remove(_tween);
		}
		else if (touch.phase == TouchPhase.MOVED)
		{
			_movement = touch.getMovement(_content);
			_position += _movement.x;
			_content.x = _position;
		}
		else if (touch.phase == TouchPhase.ENDED)
		{
			_posDelta = _posStart - _position;
			_posDeltaAbs = Math.abs(_posDelta);
			_posSign = _posDelta > 0 ? 1 : -1;
			_timeEnd = getTimer();
			_timeDelta = _timeEnd - _timeStart;

			_speed = _posDeltaAbs / _timeDelta;
			//trace("SPEED = " + _speed);

			if (_position > _offset) {
				_position = _offset;
				_pageindex = 0;
			} else {
				_position -= _offset;
				_positionAbs = Math.abs(_position);
				if (_deltawidth == 0) {
					_pageindex = Math.round(_positionAbs / _pagewidth);
				} else {
					if (_posDeltaAbs > _itemwidthhalf || _speed > 2) { // _posDelta < _pagewidth &&
						_pageindex += _posSign;
					}
				}
				if (_pageindex >= _indexies) _pageindex = _indexies - 1;
				_position = _offset - _pageindex * _pagewidth;
			}

			if(_countersize > 0) {
				_counterQuad.color = __counterColor;
				_counterQuad = _counters.getChildAt(_pageindex) as Quad;
				_counterQuad.color = __counterAColor;
			}

			_tween = new Tween(_content, 0.3, Transitions.EASE_OUT);
			_tween.animate("x", _position);
			Starling.juggler.add(_tween);
		}
	}
}
}