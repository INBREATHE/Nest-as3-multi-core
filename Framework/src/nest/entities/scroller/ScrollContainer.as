/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.scroller
{
import nest.interfaces.IScrollItem;

import starling.display.Quad;
import starling.display.Sprite;

public final class ScrollContainer extends Sprite
{
	public var
		current			: int
	,	minimum			: int
	,	maximum			: int
	,	itemsize		: int
	,	itemid			: uint

	,	fadeFromCenter	: Boolean = false
	,	doHoldAction	  : Boolean = false
	,	needTouchPoint	: Boolean = false
	,	hideInvisible	  : Boolean = false

	,	startFunction	: Function
	,	moveFunction	: Function
	,	endFunction		: Function

	,	holdStartFunction	: Function
	,	holdEndFunction		: Function
	;

	private var _type:int;
	public function get type():int { return _type; }

	public function ScrollContainer( type:int ) {
		this._type = type;
	}

	public function every( callback:Function ):void {
		var counter:uint = 1;
		while ( counter < numChildren ) {
			callback.call(null, this.getChildAt( counter++ ));
		}
	}

	public function addBackground(w:uint, h:uint):void {
		var touchBackground:Quad = Quad( this.getChildByName( "touchback" ));
		if ( !touchBackground )
			touchBackground = new Quad( w, h, 0xff00cc );

		touchBackground.x = -this.x;
		touchBackground.touchable = true;
		touchBackground.alpha = 0;
		touchBackground.name = "touchback";

		this.addChildAt( touchBackground, 0 );
	}

	public function clear():void {
		while ( this.numChildren )
			this.removeChildAt(0, true );
	}
}
}