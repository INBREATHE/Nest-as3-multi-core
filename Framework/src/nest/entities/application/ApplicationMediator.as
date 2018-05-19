/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.application
{
import nest.entities.screen.Screen;
import nest.interfaces.IMediator;
import nest.interfaces.INotification;
import nest.patterns.mediator.Mediator;
import nest.patterns.observer.NFunction;

public class ApplicationMediator extends Mediator implements IMediator
{
	static public const NAME:String = "ApplicationMediator";
	
	static private const
		APP_METHOD__PREPARE			: String = "prepare"
	,	APP_METHOD__INITIALIZED		: String = "initialized"
	,	APP_METHOD__SHOW_SCREEN		: String = "showScreen"
	,	APP_METHOD__HIDE_SCREEN		: String = "hideScreen"
	,	APP_METHOD__ADD_ELEMENT		: String = "addElement"
	,	APP_METHOD__REM_ELEMENT		: String = "removeElement"
	;

	public function ApplicationMediator(viewComponent:Object) {
		super( viewComponent );
		application.notifier = this;
	}
	
	//==================================================================================================
	override protected function listNotificationsFunctions():Vector.<NFunction> {
	//==================================================================================================
		return new <NFunction>[
			new NFunction( ApplicationNotification.SHOW_SCREEN, 		ShowScreen		)
		,	new NFunction( ApplicationNotification.HIDE_SCREEN, 		HideScreen		)

		,	new NFunction( ApplicationNotification.ADD_ELEMENT, 		APP_METHOD__ADD_ELEMENT		)
		,	new NFunction( ApplicationNotification.REMOVE_ELEMENT, APP_METHOD__REM_ELEMENT		)
		];
	}
	//==================================================================================================
	override protected function listNotificationInterests():Vector.<String> {
	//==================================================================================================
		return new <String>[
			ApplicationNotification.PREPARE
		,	ApplicationNotification.INITIALIZED
		];
	}

	//==================================================================================================
	override public function handleNotification( note:INotification ):void {
	//==================================================================================================
		var name:String = note.getName();
		var body:Object = note.getBody();
		switch (name) {
			case ApplicationNotification.PREPARE: 		name = APP_METHOD__PREPARE; 		break;
			case ApplicationNotification.INITIALIZED: 	name = APP_METHOD__INITIALIZED; 	break;
		}
		this.applyViewComponentMethod(name, body);
	}

	//==================================================================================================
	private function HideScreen( obj:Screen, nextScreenName:String ):void {
	//==================================================================================================
//		trace("> Nest -> ApplicationMediator HideScreen", obj, " \n");
		application.hideScreen(obj, nextScreenName == Screen.PREVIOUS);
	}

	//==================================================================================================
	private function ShowScreen( obj:Screen, screenName:String ):void {
	//==================================================================================================
		trace("> Nest -> ApplicationMediator ShowScreen", screenName, obj);
		application.showScreen(obj, screenName == Screen.PREVIOUS);
	}

	//==================================================================================================
	override public function onRegister():void {
	//==================================================================================================
		// This event fired after catching ApplicationNotification.INITIALIZED  
		application.addEventListener( Application.EVENT_READY, ApplicationReadyHandler );
	}

	//==================================================================================================
	private function ApplicationReadyHandler():void {
	//==================================================================================================
		this.exec( ApplicationFacade.READY );
		application.removeEventListener( Application.EVENT_READY, ApplicationReadyHandler );
	}

	//==================================================================================================
	override public function onRemove():void { super.onRemove(); }
	//==================================================================================================

	private function get application():Application { return Application(viewComponent); }
}
}
