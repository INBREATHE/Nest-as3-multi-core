/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.elements
{
import flash.system.System;
import flash.utils.setTimeout;

import nest.entities.elements.transitions.Transition;
import nest.entities.screen.Screen;

import starling.display.DisplayObjectContainer;

public class Navigator
{
	private var _container	: DisplayObjectContainer;
	private var _transition	: Transition;

	public function Navigator(container:DisplayObjectContainer, transition:Transition) {
		_container = container;
		_transition = transition;

		_transition.onHideComplete 	= RemoveScreen;
		_transition.onShowStart 	= AddScreenToApp;
		_transition.onShowComplete 	= ScreenChangeComplete;
	}

	//==================================================================================================
	public function showScreen( screen:Screen, isReturn:Boolean ):void {
	//==================================================================================================
		trace("> Nest -> Navigator : showScreen - _transition.isShowPossible =", _transition.isShowPossible)
		if(_transition.isShowPossible) {
			_container.addChild(screen);
			screen.show();
		} else {
			setTimeout(function():void { 
				_transition.show(screen, isReturn);
			}, 20);
			System.gc;
			System.pauseForGCIfCollectionImminent();
		}
	}

	//==================================================================================================
	public function hideScreen( screen:Screen, isReturn:Boolean ):void {
	//==================================================================================================
		// From base class Transistion.as
		// Default:  _transition.isHidePossible == false
		if(_transition.isHidePossible) {
			_transition.hide(screen, isReturn);
		} else {
			screen.hide(function():void {
				_transition.hide(screen, isReturn);
			});
		}
	}

	//==================================================================================================
	private function RemoveScreen(screen:Screen):void {
	//==================================================================================================
		screen.removeFromParent();
	}

	//==================================================================================================
	private function ScreenChangeComplete(screen:Screen):void {
	//==================================================================================================
		screen.show();
	}

	//==================================================================================================
	private function AddScreenToApp(screen:Screen):void {
	//==================================================================================================
		_container.addChild(screen);
	}
}
}