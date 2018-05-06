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
		_dataRequest		  : String = ""
	,	_dataNotification	: String = ""
	,	_dataForScreen		: ScreenData
	,	_isReady			    : Boolean
	;

	public var isBackPossible:Boolean = false;

	public function ScreenMediator(
		viewComponent		: Object,
		dataNotification	: String,
		dataCommand			: String = null
	) {
		this._dataRequest = dataCommand;
		this._dataNotification = dataNotification;

		super(viewComponent);

		screen.rebuildable = true;
		screen.addEventListener(Event.ADDED_TO_STAGE, Handle_AddComponentToStage);
	}

	public function get isReady():Boolean { return _isReady; }

	/**
	 * When screen mediators ready to use we first register him in ScreenProxy
	 */
	override public function onRegister():void { this.exec( ScreenCommand.REGISTER, viewComponent, this.getMediatorName() ); }
	
	private function Handle_AddComponentToStage(e:Event):void {
		trace("> Nest -> ScreenMediator > Handle_AddComponentToStage :", screen);
		screen.onAdded();
		SetupComponentListeners();
		screen.removeEventListener(	Event.ADDED_TO_STAGE, 		Handle_AddComponentToStage);
		screen.addEventListener(	Event.REMOVED_FROM_STAGE, 	Handle_RemoveComponentFromStage);
		screen.addEventListener(	Event.TRIGGERED, 			      ComponentTrigger);
	}

	private function Handle_RemoveComponentFromStage(e:Event):void {
		screen.onRemoved();
		RemoveComponentListeners();
		screen.addEventListener(	Event.ADDED_TO_STAGE, 		    Handle_AddComponentToStage);
		screen.removeEventListener(	Event.REMOVED_FROM_STAGE, 	Handle_RemoveComponentFromStage);
		screen.removeEventListener(	Event.TRIGGERED, 			      ComponentTrigger);
		if(screen.rebuildable) screen.clear();
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
	override protected function listNotificationInterests():Vector.<String> {
	//==================================================================================================
		return new <String>[
			_dataNotification
		,	ApplicationNotification.ANDROID_BACK_BUTTON
		,	ApplicationNotification.POPUP_REMOVED
		,	ApplicationNotification.POPUP_ADDED
		,	ApplicationNotification.LANGUAGE_CHANGED
		];
	}

	//==================================================================================================
	override public function handleNotification(notification:INotification):void {
	//==================================================================================================
		trace("> Nest -> ScreenMediator > " + this.getMediatorName() + " > handleNotification:", notification.getName());
		const body:Object = notification.getBody();
		const name:String = notification.getName();
		if(name == _dataNotification) { 
			SetupScreenData( body );
			ContentReady();
		}
		else if(name == ApplicationNotification.LANGUAGE_CHANGED) LocalizeScreen();
		else if(name == ApplicationNotification.ANDROID_BACK_BUTTON && screen.isShown && isBackPossible) Handle_Android_BackButton();
		else if(name == ApplicationNotification.POPUP_REMOVED) Handle_PopupClosed(uint(body), notification.getType())
		else if(name == ApplicationNotification.POPUP_ADDED) Handle_PopupOpened(uint(body), notification.getType())
	}
	
	//==================================================================================================
	protected /*abstract*/ function LocalizeScreen():void { }
	protected /*abstract*/ function SetupScreenData(data:Object):void { }
	protected /*abstract*/ function ComponentTrigger(e:Event):void { }
	protected /*abstract*/ function SetupComponentListeners():void { }
	protected /*abstract*/ function RemoveComponentListeners():void { }
	//==================================================================================================
	
	//==================================================================================================
	protected function ContentReady():void { 
	//==================================================================================================
		trace("> Application -> ScreenMediator > ContentReady: screen is ScrollScreen = " + (screen is ScrollScreen));
		if( screen is ScrollScreen && ScrollScreen(viewComponent).isScrollAvailable )
			this.send( ScrollerNotifications.SETUP_SCROLLER, ScrollScreen(viewComponent).getScrollContainer() );

		if(_dataForScreen && _dataForScreen.hasContentReadyCallback()) 
			_dataForScreen.contentReadyCallback();
		
		this.send( ApplicationNotification.SHOW_SCREEN, this.screen, _dataForScreen.previous ? Screen.PREVIOUS : screen.name );

		_dataForScreen = null;
		_isReady = true;
	}

	/**
	 * This method is called from ChangeScreenCommand
	 * screenMediator.onPrepareDataForScreen(screenData);
	 */
	//==================================================================================================
	public function prepareDataForScreen( screenData:ScreenData ):void {
	//==================================================================================================
		_dataForScreen = screenData;
		if( screen.rebuildable ) {
			_isReady = false;
			const getDataMethod:Function = facade.hasCommand(_dataRequest) ? this.exec : this.send; 
			getDataMethod( _dataRequest, _dataForScreen.data, _dataNotification );
		} else {
			ContentReady();
		}
	}

	/**
	 * This function is called when screen is hiding
	 * but before notification ApplicationNotification.HIDE_SCREEN is sent
	 * from ChangeScreenCommand
	 */
	//==================================================================================================
	public function onLeave():void {
	//==================================================================================================
		/** ANDROID - When we go to game we disable this for screen  */
		this.isBackPossible = false;
		if( viewComponent is ScrollScreen && ScrollScreen(viewComponent).isScrollAvailable ) 
			this.send( ScrollerNotifications.RESET_SCROLLER );
	}

	protected function get screen():Screen { return Screen(viewComponent); }
}
}
