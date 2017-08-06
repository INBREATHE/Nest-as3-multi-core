/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.scroller
{
import starling.display.Canvas;
import nest.entities.application.Application;

public final class ScrollCounter extends Canvas
{
	public static const
		TYPE_CIRCLE:int = 0
	,	TYPE_SQUARE:int = 1
	;

	public var currentIndex:int = -1;
	public var numChildrens:uint;

	private const
		scalefactor				: Number 	= Application.SCALEFACTOR
	,	COUNTER_SIZE			: int 		= 12 * scalefactor
	,	COUNTER_RADIUS			: int 		= COUNTER_SIZE * 0.5
	,	COUNTER_DELTA_X			: int		= 8 * scalefactor
	,	COUNTER_OFFSET			: int 		= COUNTER_SIZE + COUNTER_DELTA_X
	,	POSITION_Y				: int 		= 76 * scalefactor
	;
	private var
		_color					: uint
	,	_colorActive			: uint
	,	_type					: int
	;

	public function ScrollCounter(type:int = TYPE_CIRCLE, color:uint = 0xCCCCCC, activeColor:uint = 0x232323) {
		_type = type;
		_color = color;
		_colorActive = activeColor;
		this.y = POSITION_Y;
	}

	public function reset():void {
		currentIndex = -1;
		numChildrens = 0;
		this.clear();
	}

	override public function get width():Number {
		return (numChildrens - 1) * COUNTER_OFFSET;
	}

	public function addCount(index:uint):void {
		numChildrens++;
	}

	public function setActiveIndex(value:uint):void {
		if (this.currentIndex != value) {
			var counter:uint = numChildrens;
			var xPos:int;
			this.clear();
			while(counter--) {
				xPos = counter * COUNTER_OFFSET;
				if(counter == value) this.beginFill(_colorActive);
				else this.beginFill(_color);
				if(_type == TYPE_CIRCLE) this.drawCircle(xPos, 0, COUNTER_RADIUS);
				else if(_type == TYPE_SQUARE) this.drawRectangle(xPos, 0, COUNTER_SIZE, COUNTER_SIZE);
				this.endFill();
			}
			currentIndex = value;
		}
	}
}
}