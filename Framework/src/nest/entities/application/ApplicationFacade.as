/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.application 
{
import nest.entities.screen.ScreenCommand;
import nest.entities.screen.ScreensProxy;
import nest.entities.screen.commands.ChangeScreenCommand;
import nest.entities.screen.commands.RegisterScreenCommand;
import nest.entities.screen.commands.RemoveScreenCommand;
import nest.interfaces.IFacade;
import nest.patterns.facade.Facade;
import nest.patterns.observer.Notification;
import nest.services.localization.commands.ChangeLanguageCommand;

import starling.core.Starling;

public class ApplicationFacade extends Facade implements IFacade
{
	public static const
		STARTUP		: String = "nest_command_application_startup"
	,	READY		: String = "nest_command_application_ready"
	,	CORE		: String = "nest_application_core"
	;

	public function ApplicationFacade( key:String ):void { super( key ); }
	public static function getInstance( key:String ) : ApplicationFacade {
		var instance:ApplicationFacade = instanceMap[ key ];
		if ( instance == null ) instance  = new ApplicationFacade(key);
		return instance as ApplicationFacade;
	}

	//==================================================================================================
	override protected function initializeView():void {
	//==================================================================================================
		super.initializeView();
		
		trace("> Nest ->", multitonKey, "> ApplicationFacade > initializeView" );
		registerMediator(ApplicationMediator.NAME, new ApplicationMediator(Starling.current.root));
	}

	//==================================================================================================
	override protected function initializeModel():void {
	//==================================================================================================
		super.initializeModel();
		
		trace("> Nest ->", multitonKey, "> ApplicationFacade > initializeModel" );
		
		registerProxy( ScreensProxy );
	}

	//==================================================================================================
	override protected function initializeController():void {
	//==================================================================================================
		super.initializeController();

		trace("> Nest ->", multitonKey, "> ApplicationFacade > initializeController" );

		registerPoolCommand( ScreenCommand.REGISTER, 	RegisterScreenCommand 	);
		registerPoolCommand( ScreenCommand.CHANGE, 		ChangeScreenCommand 	);
		registerPoolCommand( ScreenCommand.REMOVE, 		RemoveScreenCommand 	); // not in use
		
//		registerPoolCommand( ApplicationCommand.SERVER_REQUEST, 		ServerRequestCommand 		);
//		registerPoolCommand( ApplicationCommand.SERVER_RESPONSE, 		ServerResponceCommand 		);
//
//		registerPoolCommand( ApplicationCommand.SINGLE_REPORT,			SendReportCommand			);
		registerPoolCommand( ApplicationCommand.CHANGE_LANGUAGE,		ChangeLanguageCommand		);
//
//		registerPoolCommand( ApplicationCommand.CACHE_BATCH_REPORT,		BatchReportsCacheCommand 	);
//		registerPoolCommand( ApplicationCommand.CACHE_BATCH_REQUESTS,	BatchRequestsCacheCommand 	);
//		registerPoolCommand( ApplicationCommand.CACHE_STORE_REPORT,		CacheReportCommand 			);
//		registerPoolCommand( ApplicationCommand.CACHE_STORE_REQUEST,	CacheRequestCommand		 	);
//		registerPoolCommand( ApplicationCommand.CACHE_CLEAR_REPORT, 	ClearReportCacheCommand 	);
//		registerPoolCommand( ApplicationCommand.CACHE_CLEAR_REQUEST, 	ClearRequestCacheCommand 	);
	}

	//==================================================================================================
	public function startup( root:Object ):void {
	//==================================================================================================
		this.executeCommand( new Notification( STARTUP, root ));
	}
}
}
