/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.popup
{
import flash.utils.Dictionary;

import nest.entities.application.ApplicationNotification;
import nest.interfaces.IMediator;
import nest.interfaces.INotification;
import nest.interfaces.IPopup;
import nest.patterns.mediator.Mediator;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public final class PopupsMediator extends Mediator implements IMediator
{
	private var popupsCount:uint = 0;
	private var popupsArray:Vector.<Popup> = new Vector.<Popup>();
	public function PopupsMediator() { super( null ); }

	override public function listNotificationInterests():Vector.<String> {
		return new <String>[
			PopupNotification.SHOW_POPUP
		,	PopupNotification.HIDE_POPUP
		,	PopupNotification.HIDE_ALL_POPUPS
		, 	ApplicationNotification.ANDROID_BACK_BUTTON
		];
	}

	override public function onRegister() : void {
		viewComponent = new Dictionary();
	}

	override public function handleNotification( note:INotification ):void {
//			trace("> PopupsMediator:", note.getName());
		switch ( note.getName() ) {
			case PopupNotification.SHOW_POPUP:
				Notification_ShowPopup(
					Popup(note.getBody())
				);
				break;
			case PopupNotification.HIDE_POPUP:
				if(popupsCount > 0)
					/**
					 * note.getType() - The name of popup
					 * note.getBody() - force delete (without popup.hide)
					 */
					Notification_HidePopup(	String(note.getType()), Boolean(note.getBody()) || false );
				break;
			case PopupNotification.HIDE_ALL_POPUPS:
				if(popupsCount > 0) Notification_HideAllPopups();
				break;
			case ApplicationNotification.ANDROID_BACK_BUTTON:
				if(popupsCount > 0) Notification_AndroidBackButton();
				break;
		}
	}

	//==================================================================================================
	private function Notification_ShowPopup(popup:Popup):void {
	//==================================================================================================
		if (GetPopupByName(popup.name) != null) RemovePopupFromStage(popup.name);
		this.AddPopup(popup);
	}

	//==================================================================================================
	private function Notification_HideAllPopups():void {
	//==================================================================================================
		for (var name:String in Dictionary(viewComponent)) RemovePopupFromStage(name);
	}

	//==================================================================================================
	private function Notification_HidePopup(popupName:String, force:Boolean):void {
	//==================================================================================================
		const popup:Popup = this.GetPopupByName(popupName);
		if (popup) {
			if(force) RemovePopupFromStage(popup.name);
			else popup.hide(RemovePopupFromStage);
		}
	}

	//==================================================================================================
	private function Notification_AndroidBackButton():void {
	//==================================================================================================
		const popup:Popup = popupsArray[popupsCount-1];
		if (popup && popup.parent && popup.backRemovable) {
			popup.androidBackButtonPressed();
			popup.hide(RemovePopupFromStage);
		}
	}

	//==================================================================================================
	private function RemovePopupFromStage(name:String):void {
	//==================================================================================================
		const popup:Popup = this.GetPopupByName(name);
		if(popup == null) return;

		RemoveListeners(popup);
		Starling.juggler.removeTweens(popup);
		this.RemovePopupByName(name);

		this.send(ApplicationNotification.REMOVE_ELEMENT, popup);
		this.send(ApplicationNotification.POPUP_CLOSED, popupsCount, name);
	}

	//==================================================================================================
	private function AddPopupToStageAndShow(value:DisplayObject):void {
	//==================================================================================================
		SetupListeners(value);
		this.send( ApplicationNotification.ADD_ELEMENT, value );
		this.send( ApplicationNotification.POPUP_OPENED, popupsCount, Popup(value).name );
		IPopup(value).show();
	}

	//==================================================================================================
	private function Handle_ClosePopup(e:Event):void {
	//==================================================================================================
		const popup:Popup = Popup(e.currentTarget);
		popup.hide(function(popupname):Function{ return function():void{ RemovePopupFromStage(popupname)} }(popup.name));
	}

	//==================================================================================================
	private function Handle_CommandFromPopup(e:Event, data:Object):void {
	//==================================================================================================
		const popup		: Popup = Popup(e.currentTarget);
		const command	: String = IPopup(popup).command;
		if(command) AnalyzeDataAndSendCommand(command, data);
	}

	//==================================================================================================
	private function AnalyzeDataAndSendCommand(command:String, data:*):void {
	//==================================================================================================
		if( data is Array ) this.exec( command, data[0], data[1] );
		else if( data is PopupEventData ) this.exec( command, PopupEventData(data).body, PopupEventData(data).type );
		else this.exec( command, data );
	}

	//==================================================================================================
	private function SetupListeners(popup:DisplayObject):void {
	//==================================================================================================
		popup.addEventListener(PopupEvents.COMMAND_FROM_POPUP, Handle_CommandFromPopup);

		popup.addEventListener(PopupEvents.TAP_HAPPEND_OK, 		Handle_ClosePopup);
		popup.addEventListener(PopupEvents.TAP_HAPPEND_CLOSE, 	Handle_ClosePopup);
	}

	//==================================================================================================
	private function RemoveListeners(popup:DisplayObject):void {
	//==================================================================================================
		if(!popup.hasEventListener(PopupEvents.COMMAND_FROM_POPUP)) return;
		popup.removeEventListener(PopupEvents.COMMAND_FROM_POPUP, Handle_CommandFromPopup);

		popup.removeEventListener(PopupEvents.TAP_HAPPEND_OK, 	Handle_ClosePopup);
		popup.removeEventListener(PopupEvents.TAP_HAPPEND_CLOSE, Handle_ClosePopup);
	}

	//==================================================================================================
	private function GetPopupByName(name:String):Popup {
	//==================================================================================================
		if(name == null) name = popupsArray[popupsCount-1].name;
		return Dictionary(viewComponent)[name];
	}

	//==================================================================================================
	private function AddPopup(value:Popup):void {
	//==================================================================================================
		const prioriter:int = value.prioritet;

		var counter:uint = popupsCount;
		var tempPopup:Popup;
		while(counter--) {
			tempPopup = popupsArray[counter];
			if(value.prioritet >= tempPopup.prioritet){
				value.localIndex = counter+1;
				break;
			}
		}

		popupsArray.insertAt(value.localIndex, value);
		popupsCount++;

		Dictionary(viewComponent)[value.name] = value;
		if(value.parent == null) AddPopupToStageAndShow(value);
		else IPopup(value).show();
	}

	//==================================================================================================
	private function RemovePopupByName(name:String):void {
	//==================================================================================================
		const popup:Popup = Dictionary(viewComponent)[name];
		popupsArray.removeAt(popup.localIndex);
		Dictionary(viewComponent)[name] = null;
		delete Dictionary(viewComponent)[name];
		popup.localIndex = 0;
		popupsCount--;
	}
}
}
