/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.application
{
import flash.desktop.NativeApplication;
import flash.display.DisplayObjectContainer;
import flash.events.KeyboardEvent;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.setTimeout;

import nest.Enviroment;
import nest.entities.elements.Element;
import nest.entities.elements.Navigator;
import nest.entities.elements.transitions.FadeTransition;
import nest.entities.screen.Screen;
import nest.interfaces.IElement;
import nest.interfaces.INotifier;

import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;

/**
 * This is screen navigator and main class of application
 * @author Vladimir Minkin
 * VERSION 0.86
 */
public class Application extends Sprite
{
	static private var console:TextField;
	public static function log(...message):void { if(console) console.text = "\n> " + message + console.text; else trace(message); }
	//==================================================================================================
	public static function setupConsole(stage:DisplayObjectContainer, fontSize:uint = 15, fontColor:uint = 0xff0000):void {
	//==================================================================================================
		console = new TextField();
		console.defaultTextFormat = new TextFormat(null, fontSize, fontColor);
		console.width = Capabilities.screenResolutionX;
		console.height = Capabilities.screenResolutionY;
		
		stage.addChild(console);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.C:
					console.text = "";
					break;
			}
		});
	}
	
	static public var isPhone			: Boolean;

	static public var EVENT_READY : String = "application_event_ready";
	
	static public var SCALEFACTOR		: Number = 1;
	static public var SCREEN_WIDTH		: uint = Capabilities.screenResolutionX;
	static public var SCREEN_HEIGHT		: uint = Capabilities.screenResolutionY;

	public static const ENVIROMENT:Enviroment = new Enviroment();
	
	private const _screensContainer : Element = new Element(ENVIROMENT);
	private const _navigator		: Navigator = new Navigator(_screensContainer, new FadeTransition());

	protected var _notifier	: INotifier;

	public function Application() 
	{
		this.addElement(_screensContainer);

		if(ENVIROMENT.isAndroid || Capabilities.isDebugger)
		{
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown)
		}
	}
	
	

	//==================================================================================================
	public function addElement(obj:DisplayObject):void {
	//==================================================================================================
		if (obj is IElement) {
			this.addChildAt(obj, getObjectPositionWithPrioriotet(IElement(obj).order))
		} else {
			this.addChild(obj);
		}
	}

	//==================================================================================================
	public function removeElement(obj:DisplayObject):void {
	//==================================================================================================
		obj.removeFromParent();
	}

	//==================================================================================================
	public function showScreen(obj:Screen, isReturn:Boolean = false):void {
	//==================================================================================================
		_navigator.showScreen(obj, isReturn);
	}

	//==================================================================================================
	public function hideScreen(obj:Screen, isReturn:Boolean = false):void {
	//==================================================================================================
		_navigator.hideScreen(obj, isReturn);
	}

	/**
	 * This is the first method that called when framework start
	 * Sent from PrepareBegin command
	 * */
	//==================================================================================================
	public function prepare():void { }
	//==================================================================================================

	//==================================================================================================
	public function initialized():void {
	//==================================================================================================
		this.dispatchEventWith( EVENT_READY );
	}

	//==================================================================================================
	public function set notifier(value:INotifier):void {
	//==================================================================================================
		_notifier = value;
	}

	//==================================================================================================
	public function getObjectPositionWithPrioriotet(prioritet:int):uint {
	//==================================================================================================
		var counter:uint = this.numChildren;
		if(counter > 0) {
			var child:DisplayObject = DisplayObject(this.getChildAt(--counter));
			while (counter && child is IElement) {
				if (IElement(child).order <= prioritet) break;
				child = DisplayObject(this.getChildAt(--counter));
			}
			return ++counter;
		} else return counter;
	}

	//==================================================================================================
	protected function onKeyDown(event:KeyboardEvent):void {
	//==================================================================================================
		if( event.keyCode == Keyboard.BACK )
		{
			event.preventDefault(); 
			event.stopImmediatePropagation();
			_notifier.send( ApplicationNotification.ANDROID_BACK_BUTTON );
		}
	}
}
}
