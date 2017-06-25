/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.popup
{
import nest.entities.elements.Element;
import nest.interfaces.IPopup;

public class Popup extends Element implements IPopup
{
	protected var _commandID:uint;
	protected var _commands:Array;
	protected var _locale:XMLList;

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
	}

	protected function dispatchToExecuteCommand(commandID:uint, data:Object = null, type:String = null):void {
		_commandID = commandID;
		if(type != null) data = new PopupEventData(data, type);
		this.dispatchEventWith(PopupEvents.COMMAND_FROM_POPUP, false, data);
	}

	//==================================================================================================
	public function setup( data:Object ):void { }
	public function localize( data:XMLList ):void { _locale = data; }
	public function prepare( params:Object ):void { }
	/**
	 * ANDROID ONLY
	 * Only for back button press
	 */
	public function androidBackButtonPressed ( ):void { }

	public function show():void { }
	public function hide(next:Function):void { next.apply(null, [this.name]); }
	public function get command():String { return _commands[_commandID]; }
	public function set commands(value:Array):void { _commands = value; }
	//==================================================================================================
}
}