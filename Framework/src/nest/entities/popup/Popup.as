/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.popup
{
import nest.entities.EntityType;
import nest.entities.elements.Element;
import nest.interfaces.IPopup;

import starling.events.Event;

public class Popup extends Element implements IPopup
{
	protected var 
		_actionID	: uint
	,	_actions	: Array
	,	_locale		: XMLList

	,	_onAdded	: Function
	,	_onShown	: Function
	,	_onRemoved	: Function
	;
	
	/**
	 * This is a number in popupsArray
	 * It's used for removing popups from screen
	 * when android back button is pressed
	 */
	public var localIndex:uint = 0;
	/**
	 * Check if remove operation for popup is available
	 */
	public var backRemovable:Boolean = true;

	public function Popup( name : String ) {
		this.name = name;
		super();
		this.addEventListener( Event.ADDED_TO_STAGE, Handler_ADDED_TO_STAGE );
	}
	
	//==================================================================================================
	private function Handler_REMOVED_FROM_STAGE(e:Event):void {
	//==================================================================================================
		this.addEventListener( Event.ADDED_TO_STAGE, Handler_ADDED_TO_STAGE);
		this.removeEventListener( Event.REMOVED_FROM_STAGE, Handler_REMOVED_FROM_STAGE);
		
		_onRemoved && _onRemoved() && (_onRemoved = null) && (_onShown = null);
	}
	
	//==================================================================================================
	private function Handler_ADDED_TO_STAGE(e:Event):void {
	//==================================================================================================
		this.removeEventListener( Event.ADDED_TO_STAGE, Handler_ADDED_TO_STAGE);
		this.addEventListener( Event.REMOVED_FROM_STAGE, Handler_REMOVED_FROM_STAGE);
		
		_onAdded && _onAdded() && (_onAdded = null);
	}

	//==================================================================================================
	protected function dispatchToExecuteAction(actionID:uint, data:PopupEventData = null):void {
	//==================================================================================================
		_actionID = actionID;
		this.dispatchEventWith(PopupEvents.ACTION_FROM_POPUP, false, data);
	}

	//==================================================================================================
	public function setup( popupData:PopupData ):void {
	//==================================================================================================
		_onAdded 	= popupData.onAdded;
		_onShown 	= popupData.onShown;
		_onRemoved 	= popupData.onRemoved;
		
		prepare(popupData.data);
	}

	public function localize( data:XMLList ):void { _locale = data; }
	public function getLocaleID():String { return this.name; }
	public function getEntityType():uint { return EntityType.POPUP; }

	public function prepare( params:Object ):void { }
	/**
	 * ANDROID ONLY
	 * Only for back button press
	 */
	public function androidBackButtonPressed ( ):void { }

	public function show():void { }
	public function hide(next:Function):void { next.apply(null, [this.name]); }
	public function get command():String { return _actions[_actionID]; }
	public function set actions(value:Array):void { _actions = value; }
	//==================================================================================================
}
}