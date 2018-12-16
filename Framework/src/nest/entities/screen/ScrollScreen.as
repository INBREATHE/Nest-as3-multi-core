/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.screen
{
import nest.entities.scroller.ScrollContainer;
import nest.entities.scroller.ScrollCounter;
import nest.interfaces.IScrollItem;

public class ScrollScreen extends Screen
{
	protected var
		_scrollContainer	: ScrollContainer
	,	_scrollCounter		: ScrollCounter
	;

	private var _isScrollAvailable:Boolean = false;
	public function get isScrollAvailable():Boolean { return _isScrollAvailable; }

	public function ScrollScreen( screenName:String ) {
		super( screenName );
	}

	//==================================================================================================
	public function initScrollContainer( type:int ):void {
	//==================================================================================================
		_scrollContainer 	= new ScrollContainer( type );
		_scrollCounter 		= new ScrollCounter();
		_isScrollAvailable 	= true;
	}

	//==================================================================================================
	override public function clear():void {
	//==================================================================================================
		if( _scrollContainer ) _scrollContainer.clear();
		if( _scrollCounter ) _scrollCounter.reset();
	}

	//==================================================================================================
	public function checkIfTouchPossible(scrollItem:IScrollItem):Boolean {
	//==================================================================================================
		const result : Boolean = this.isShown && !scrollItem.isLocked();
//		trace("> Application -> ScrollScreen > checkIfTouchPossible: this.isShown =", this.isShown);
//		trace("> Application -> ScrollScreen > checkIfTouchPossible: scrollItem.isLocked =", scrollItem.isLocked());
		return result;
	}

	//==================================================================================================
	public function getScrollContainer():ScrollContainer {
	//==================================================================================================
		_scrollContainer.current = _scrollContainer.x;
		return _scrollContainer;
	}
}
}
