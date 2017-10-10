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
	private const popupsQueue:Vector.<Popup> = new Vector.<Popup>();
	private const popupsStorage:Dictionary = new Dictionary();

	public function PopupsMediator() { super( null ); }

	override public function listNotificationInterests():Vector.<String> {
		return new <String>[
			PopupNotification.SHOW_POPUP
		,	PopupNotification.SHOW_POPUP_BY_NAME
		,	PopupNotification.HIDE_POPUP
		,	PopupNotification.REGISTER_POPUP
		,	PopupNotification.HIDE_ALL_POPUPS
		,	PopupNotification.UNLOCK_POPUP
		,	PopupNotification.UPDATE_POPUP
		, 	ApplicationNotification.ANDROID_BACK_BUTTON
		, 	ApplicationNotification.LANGUAGE_CHANGED
		];
	}

	override public function onRegister() : void {
		setViewComponent(new Dictionary());
	}

	override public function handleNotification( note:INotification ):void {
		switch ( note.getName() ) {
			case PopupNotification.REGISTER_POPUP: Notification_RegisterPopup(Popup(note.getBody())); break;
			case PopupNotification.SHOW_POPUP_BY_NAME: Notification_ShowPopupByName(PopupData(note.getBody()), note.getType()); break;
			case PopupNotification.SHOW_POPUP: Notification_ShowPopup(Popup(note.getBody())); break;
			case PopupNotification.HIDE_POPUP:
				if(popupsCount > 0)
					/**
					 * note.getType() - The name of popup
					 * note.getBody() - force delete (without popup.hide)
					 */
					Notification_HidePopup(	String(note.getType()), Boolean(note.getBody()) || false );
				break;
			case PopupNotification.HIDE_ALL_POPUPS: Notification_HideAllPopups(); break;
			case PopupNotification.UNLOCK_POPUP: Notification_UnlockPopup(String(note.getBody())); break;
			case PopupNotification.UPDATE_POPUP: Notification_UpdatePopup(note.getBody(), String(note.getType())); break;
			case ApplicationNotification.ANDROID_BACK_BUTTON: Notification_AndroidBackButton(); break;
		}
	}
	
	//==================================================================================================
	private function Notification_UpdatePopup(popupData:Object, popupName:String):void {
	//==================================================================================================
		trace("> Nest -> PopupsMediator > Notification_UpdatePopup:", popupName, popupData)
		if(popupName == null) return;
		const popup:Popup = popupsStorage[popupName];
		popup.prepare(popupData);
	}
	
	//==================================================================================================
	private function Notification_UnlockPopup(popupName:String):void {
	//==================================================================================================
		trace("> Nest -> PopupsMediator > Notification_UnlockPopup:", popupName)
		if(popupName == null) return;
		const popup:Popup = popupsStorage[popupName];
		popup.touchable = true;
	}
	//==================================================================================================
	private function Notification_ShowPopupByName(popupData:PopupData, name:String):void {
	//==================================================================================================
		const popup:Popup = popupsStorage[name];
		trace("> Nest -> PopupsMediator > Notification_ShowPopupByName:", name)
		if (GetPopupByName(name) != null) 
			popup.hide(function():void {
				trace("> Nest -> PopupsMediator > Hide Popup:", name)
				RemovePopupFromStage(name);
				popup.setup(popupData);
				AddPopup(popup);
			});
		else {
			popup.setup(popupData);
			this.AddPopup(popup);
		}
	}
	
	//==================================================================================================
	private function Notification_RegisterPopup(popup:Popup):void {
	//==================================================================================================
		popupsStorage[popup.name] = popup;
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
		if(popupsCount > 0) for (var name:String in Dictionary(viewComponent)) RemovePopupFromStage(name);
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
		if(popupsCount > 0) {
			const popup:Popup = popupsQueue[popupsCount-1];
			if (popup && popup.parent && popup.backRemovable) {
				popup.androidBackButtonPressed();
				popup.hide(RemovePopupFromStage);
			}
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
		value.touchable = false;
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
		if(command) {
			if( data is Array ) (facade.hasCommand(command) ? exec : send)( command, data[0], data[1] );
			else (facade.hasCommand(command) ? exec : send)( command, data );
		}
	}

	//==================================================================================================
	private function SetupListeners(popup:DisplayObject):void {
	//==================================================================================================
		popup.addEventListener(PopupEvents.COMMAND_FROM_POPUP, Handle_CommandFromPopup);

		popup.addEventListener(PopupEvents.POPUP_SHOWN, 		Handle_PopupShown);
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
	
	private function Handle_PopupShown(e:Event):void
	{
		const popup:Popup = Popup(e.currentTarget);
		popup.removeEventListener(PopupEvents.POPUP_SHOWN, 	Handle_PopupShown);
		popup.touchable = true;
	}
	
	//==================================================================================================
	private function GetPopupByName(name:String):Popup {
	//==================================================================================================
		if(name == null) name = popupsQueue[popupsCount-1].name;
		return Dictionary(viewComponent)[name];
	}

	//==================================================================================================
	private function AddPopup(value:Popup):void {
	//==================================================================================================
		var counter:uint = popupsCount;
		var tempPopup:Popup;
		while(counter--) {
			tempPopup = popupsQueue[counter];
			if(value.order >= tempPopup.order){
				value.localIndex = counter + 1;
				break;
			}
		}

		popupsQueue.insertAt(value.localIndex, value);
		popupsCount++;

		Dictionary(viewComponent)[value.name] = value;
		if(value.parent == null) AddPopupToStageAndShow(value);
		else IPopup(value).show();
	}

	//==================================================================================================
	private function RemovePopupByName(name:String):void {
	//==================================================================================================
		const popup:Popup = Dictionary(viewComponent)[name];
		popupsQueue.removeAt(popup.localIndex);
		Dictionary(viewComponent)[name] = null;
		delete Dictionary(viewComponent)[name];
		popup.localIndex = 0;
		popupsCount--;
	}
}
}
