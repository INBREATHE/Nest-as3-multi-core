/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.screen
{
import nest.interfaces.IScreen;
import starling.display.Sprite;

public class Screen extends Sprite implements IScreen
{
	public static const PREVIOUS:String = "nest_screen_mark_previous";
	public static var
		sf					: Number	= 0
	,	sw					: uint 		= 0
	,	sh					: uint 		= 0
	,	swhalf				: uint		= 0
	,	shhalf				: uint		= 0
	
	;
	protected var _currentLanguage:String;
	protected var _locale:XMLList;

	public var isShown	: Boolean = false;
	public var isBuild	: Boolean = false;
	// Should it be clear from Stage
	// Work only with _rebuild == true (ScreenMediator)
	public var isClearWhenRemove:Boolean = false;

	public function Screen(name:String) {
		this.name = name;
		this.touchable = false;
	}

	//==================================================================================================
	public function show():void {
	//==================================================================================================
		isShown = true;
		this.touchable = true;
	}

	//==================================================================================================
	public function hide(callback:Function = null):void {
	//==================================================================================================
		isShown = false;
		this.touchable = false;
		if(callback) callback.call();
	}

	//==================================================================================================

	/**
	 *  This function called when screen remove but only:
	 * if(_rebuild && screen.isClearWhenRemove) screen.clear();
	 * from ScreenMediator
	*/
	public /*abstract*/ function clear():void { }
	public /*abstract*/ function build(content:Object):void { }
	public /*abstract*/ function prepare(content:Object):void {  }

	public function onAdded():void { }
	public function onRemoved():void { }

	/**
	 * First application send notification ScreenCommand.LOCALIZE
	 * with parameter: body = language
	 * Initial command SetupLanguageMiscCommand
	 */
	public function localize(lang:String, data:XMLList = null):void {
		_currentLanguage = lang;
		_locale = data;
	}
	//==================================================================================================
}
}