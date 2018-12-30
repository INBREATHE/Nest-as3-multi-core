/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.popup
{
import flash.utils.Dictionary;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import nest.entities.EntityType;
import nest.entities.application.Application;
import nest.entities.elements.Element;
import nest.interfaces.IPopup;

import starling.display.DisplayObject;
import starling.events.Event;

public class Popup extends Element implements IPopup
{
	protected var 
		_actions	  : Dictionary = new Dictionary()
	,	_locale		  : XMLList

	,	_onAdded	  : Function
	,	_onShown	  : Function
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
		super( Application.ENVIRONMENT );
		this.addEventListener( Event.ADDED_TO_STAGE, Handler_ADDED_TO_STAGE );
	}
	
	// This method called from RemovePopupFromStage only in case when forcing it to close
	// Notification_HideAllPopups or Notification_HidePopup(name, force==true)
	public function clear():void {
		_onRemoved = null;
		_onAdded = null;
		_onShown = null;
	}
	
	//==================================================================================================
	private function Handler_REMOVED_FROM_STAGE(e:Event):void {
	//==================================================================================================
		this.addEventListener( Event.ADDED_TO_STAGE, Handler_ADDED_TO_STAGE);
		this.removeEventListener( Event.REMOVED_FROM_STAGE, Handler_REMOVED_FROM_STAGE);
		trace("> Nest -> Popup", this, DisplayObject(e.currentTarget).parent ," > REMOVED_FROM_STAGE : _onRemoved", _onRemoved);
		
		if(_onRemoved){
			const onRemove:Function = _onRemoved;
			clear();
			const timeoutID:uint = setTimeout(function():void{
				clearTimeout(timeoutID);
				onRemove(); 
			}, 0);
		}
	}
	
	//==================================================================================================
	private function Handler_ADDED_TO_STAGE(e:Event):void {
	//==================================================================================================
		this.removeEventListener( Event.ADDED_TO_STAGE, Handler_ADDED_TO_STAGE);
		this.addEventListener( Event.REMOVED_FROM_STAGE, Handler_REMOVED_FROM_STAGE);
		
		if ( _onAdded ) {
			const onAdded:Function = _onAdded;
			_onAdded = null;
			onAdded();
		}
	}

	//==================================================================================================
	public function setup( popupData:PopupData ):void {
	//==================================================================================================
		_onAdded 	= popupData.onAdded;
		_onShown 	= popupData.onShown;
		_onRemoved 	= popupData.onRemoved;
		
		trace("> Nest -> Popup > setup: _onRemoved", _onRemoved != null);
		trace("> Nest -> Popup > setup: _onShown", _onShown != null);
		trace("> Nest -> Popup > setup: _onAdded", _onAdded != null);
		
		prepare( popupData.data );
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
	public function hide( next:Function ):void { next.apply(null, [this.name]); }
	public function addAction( action:PopupAction ):void {
		_actions[ action.id ] = action;
	}

	public function addActions( input:Array ):void {
		input.forEach(function (action:PopupAction, index:int, s:Array):void {
			addAction( action );
		});
	}

	public function getAction( actionID:String ):PopupAction {
		return _actions[ actionID ];
	}

	protected function dispatchAction( action:PopupAction ):void {
		dispatchEventWith( PopupEvents.ACTION_FROM_POPUP, false, action );
	}

	protected function dispatchActions( input:Array ):void {
		for each ( var action:PopupAction in input )
			dispatchAction( action );
	}
	//==================================================================================================
}
}