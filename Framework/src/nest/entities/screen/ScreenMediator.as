/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.screen
{
import nest.entities.application.ApplicationNotification;
import nest.entities.scroller.ScrollerNotifications;
import nest.interfaces.IMediator;
import nest.interfaces.INotification;
import nest.patterns.mediator.Mediator;

import starling.events.Event;

public class ScreenMediator extends Mediator implements IMediator
{
	private var
		_rebuild			: Boolean = false
	,	_dataCommand		: String = ""
	,	_dataNotification	: String = ""
	;

	public var
		isBackPossible:Boolean = false;

	public function ScreenMediator(
		viewComponent		: Object,
		dataNotification	: String,
		dataCommand			: String = null,
		rebuild				: Boolean = false
	) {
		super(viewComponent);

		this._rebuild = rebuild;
		this._dataCommand = dataCommand;
		this._dataNotification = dataNotification;

		screen.addEventListener(Event.ADDED_TO_STAGE, Handle_AddComponentToStage);
	}

	/**
	 * When screen mediator ready to use we first register him in ScreenProxy
	 */
	override public function onRegister():void {
		this.exec( ScreenCommand.REGISTER, viewComponent, mediatorName );
	}

	private function Handle_AddComponentToStage(e:Event):void {
//		trace("> Nest -> ScreenMediator > Handle_AddComponentStage", screen);
		screen.onAdded();
		OnScreenAddedToStage();
		screen.removeEventListener(	Event.ADDED_TO_STAGE, 		Handle_AddComponentToStage);
		screen.addEventListener(	Event.REMOVED_FROM_STAGE, 	Handle_RemoveComponentFromStage);
		screen.addEventListener(	Event.TRIGGERED, 			ComponentTrigger);
	}

	private function Handle_RemoveComponentFromStage(e:Event):void {
//		trace("> Nest -> ScreenMediator > Handle_RemoveComponentStage", screen);
		screen.onRemoved();
		OnScreenRemovedFromStage();
		screen.addEventListener(	Event.ADDED_TO_STAGE, 		Handle_AddComponentToStage);
		screen.removeEventListener(	Event.REMOVED_FROM_STAGE, 	Handle_RemoveComponentFromStage);
		screen.removeEventListener(	Event.TRIGGERED, 			ComponentTrigger);
		if(_rebuild && screen.isClearWhenRemove) {
			screen.clear();
		}
	}

	/**
	 * Sent from PlaywordsLogic but only if isAndroid || Capabilities.isDebugger
	*/
	//==================================================================================================
	protected function Handle_Android_BackButton():void { }
	//==================================================================================================

	/**
	 * Sent only from PopupsMediator when notification happen PopupNotification.HIDE_POPUP
	 * from method RemovePopupFromStage.
	 * */
	//==================================================================================================
	protected function Handle_PopupClosed(popupCount:uint, popupName:String):void {
	//==================================================================================================
		if(popupCount == 0 && screen.isShown) this.isBackPossible = true;
	}

	/**
	 * Sent only from PopupsMediator when notification happen PopupNotification.SHOW_POPUP
	 * from method AddPopupToStageAndShow.
	 * */
	//==================================================================================================
	protected function Handle_PopupOpened(popupCount:uint, popupName:String):void { this.isBackPossible = false; }
	//==================================================================================================
	
	//==================================================================================================
	protected function OnScreenAddedToStage():void {}
	protected function OnScreenRemovedFromStage():void {}
	protected function OnScreenShown():void {}
	//==================================================================================================
	
	//==================================================================================================
	override public function listNotificationInterests():Vector.<String> {
	//==================================================================================================
		return new <String>[
			_dataNotification
		,	ApplicationNotification.ANDROID_BACK_BUTTON
		,	ApplicationNotification.POPUP_CLOSED
		,	ApplicationNotification.POPUP_OPENED
		,	ApplicationNotification.LANGUAGE_CHANGED
		];
	}

	//==================================================================================================
	override public function handleNotification(notification:INotification):void {
	//==================================================================================================
//		trace("> Nest -> ScreenMediator > handleNotification:", notification.getName());
		const body:Object = notification.getBody();
		const name:String = notification.getName();
		if(name == _dataNotification) { ComponentDataReady( body ); ContentReady(); }
		else if(name == ApplicationNotification.LANGUAGE_CHANGED) LocalizeScreen();
		else if(name == ApplicationNotification.ANDROID_BACK_BUTTON && screen.isShown && isBackPossible) Handle_Android_BackButton();
		else if(name == ApplicationNotification.POPUP_CLOSED) Handle_PopupClosed(uint(body), notification.getType())
		else if(name == ApplicationNotification.POPUP_OPENED) Handle_PopupOpened(uint(body), notification.getType())
	}
	
	//==================================================================================================
	private function LocalizeScreen():void {
	//==================================================================================================
		
	}

	//==================================================================================================
	protected function ContentReady(isReturn:Boolean = false):void {
	//==================================================================================================
//		trace("> Nest -> ScreenMediator > ContentReady:", screen);
		SetupComponentListeners();
		SetupScrollerIfAvailable();
		screen.isBuild = !_rebuild;
		this.isBackPossible = true;
		this.send( ApplicationNotification.SHOW_SCREEN, Screen(viewComponent), isReturn ? "" : null );
	}

	//==================================================================================================
	protected /*abstract*/ function ComponentDataReady(data:Object):void { }
	protected /*abstract*/ function ComponentTrigger(e:Event):void { }
	protected /*abstract*/ function SetupComponentListeners():void { }
	protected /*abstract*/ function RemoveComponentListeners():void { }
	//==================================================================================================

	//==================================================================================================
	public function onReturn(screenData:Object):void {
	//==================================================================================================
//		trace("> Nest -> ScreenMediator > onReturn:", Screen(viewComponent));
		ContentReady(true);
	}

	/**
	 * This method is called from ChangeScreenCommand
	 * 	if(goPrevious) screenMediator.onReturn();
	 *	else screenMediator.onPrepare(screenData);
	 */
	//==================================================================================================
	public function onPrepare(screenData:Object = null):void {
	//==================================================================================================
//		trace("> Nest -> ScreenMediator > onPrepare:", Screen(viewComponent));
		if(!screen.isBuild) this.getDataForScreen( screenData );
		else ContentReady();
	}

	/**
	 * This function is called when screen is hiding
	 * but before notification ApplicationNotification.HIDE_SCREEN is sent
	 * from ChangeScreenCommand
	 */
	//==================================================================================================
	public function onLeave():void {
	//==================================================================================================
//		trace("> Nest -> ScreenMediator > onLeave:", Screen(viewComponent));
		/** ADNROID - When we go to game we disable this for screen  */
		this.isBackPossible = false;
		RemoveScrollerIfAvailable();
		RemoveComponentListeners();
	}

	//==================================================================================================
	public function getDataForScreen(criteria:Object = null):void {
	//=================================================================================================
		this.exec( _dataCommand, criteria );
	}

	//==================================================================================================
	private function SetupScrollerIfAvailable():void {
	//==================================================================================================
		if( viewComponent is ScrollScreen && ScrollScreen(viewComponent).isScrollAvailable )
			this.send( ScrollerNotifications.SETUP_SCROLLER, ScrollScreen(viewComponent).getScrollContainer() );
	}

	//==================================================================================================
	private function RemoveScrollerIfAvailable():void {
	//==================================================================================================
		if( viewComponent is ScrollScreen && ScrollScreen(viewComponent).isScrollAvailable ) this.send( ScrollerNotifications.RESET_SCROLLER );
	}

	protected  function get screen():Screen { return Screen(viewComponent); }

}
}
