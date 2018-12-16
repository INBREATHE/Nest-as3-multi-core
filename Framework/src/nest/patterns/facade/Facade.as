/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.patterns.facade
{
import flash.utils.Dictionary;

import nest.core.Controller;
import nest.core.Model;
import nest.core.View;
import nest.interfaces.IController;
import nest.interfaces.IFacade;
import nest.interfaces.ILanguageDependent;
import nest.interfaces.IMediator;
import nest.interfaces.IModel;
import nest.interfaces.INotification;
import nest.interfaces.IProxy;
import nest.interfaces.IView;

public class Facade implements IFacade
{
	static protected var instance : IFacade;

	// Message Constants
	static public const MULTITON_MSG:String = "Facade instance for this Multiton key already constructed!";
	static protected const instanceMap : Dictionary = new Dictionary(true);

	protected var
		controller 	: IController
	,	model		    : IModel
	,	view		    : IView
	;

	protected var multitonKey : String;
	public function get key():String { return multitonKey; }

	public static function getInstance( key:String ):IFacade {
		instance = instanceMap[ key ];
		if ( instance == null ) instance = new Facade( key );
		return instance;
	}

	public function Facade( key:String ) {
		if ( instanceMap[ key ] != null ) throw Error( MULTITON_MSG );
		multitonKey = key;
		instanceMap[ multitonKey ] = this;
		initializeFacade();
	}

	protected function initializeFacade():void {
		initializeModel();
		initializeController();
		initializeView();
	}

	private var _language:String;

	// PROPERTIES
	//========================================================================================================================================
	public function get currentLanguage() : String { return _language; }
	public function set currentLanguage( value : String ):void {
		_language = value;
		( model as ILanguageDependent ).languageChanged();
	}
	//========================================================================================================================================

	// INITIALIZE
	//========================================================================================================================================
	protected function initializeController()	: void { if ( controller == null ) controller = Controller.getInstance( multitonKey ); }
	protected function initializeModel()		  : void { if ( model == null ) model = Model.getInstance( multitonKey ); }
	protected function initializeView()			  : void { if ( view == null ) view = View.getInstance( multitonKey ); }
	//========================================================================================================================================

	// REGISTER
	//========================================================================================================================================
	public function registerProxy 			  ( proxyClass : Class )			    : void 		{ model.registerProxy ( proxyClass ); 			}
	public function registerProcess			  ( process : Class )				      : void 		{ }
	public function registerCommand			  ( name : String, clss : Class )	: void 		{ controller.registerCommand( name, clss );  	}
	public function registerPoolCommand		( name : String, clss : Class )	: void 		{ controller.registerPoolCommand( name, clss );  	}

	public function registerCountCommand	( name : String, clss : Class, count : int ) : void { controller.registerCountCommand( name, clss, count );  	}

	public function registerMediator		  ( name:String, mediator : IMediator )		: void 		{ view.registerMediator( name, mediator ); 			}
	//========================================================================================================================================

	// HAS
	//========================================================================================================================================
	public function hasProxy			  ( proxyClass : Class ) 		: Boolean 	{ return model.hasProxy( proxyClass ); }
	public function hasProcess			( process : Class ) 			: Boolean 	{ return false; }
	public function hasCommand			( commandName : String ) 	: Boolean 	{ return controller.hasCommand( commandName ); }
	public function hasMediator			( mediatorName : String ) : Boolean 	{ return view.hasMediator( mediatorName ); }
	//========================================================================================================================================

	// RETRIEVE
	//========================================================================================================================================
	public function getProxy 			( proxyClass : Class )			: IProxy 	{ return model.retrieveProxy ( proxyClass ); }
	public function getMediator		( mediatorName : String )		: IMediator { return view.retrieveMediator( mediatorName ) as IMediator; }
	//========================================================================================================================================

	// REMOVE
	//========================================================================================================================================
	public function removeProxy 		( proxyClass : Class )			: IProxy 	{ return model.removeProxy ( proxyClass ); }
	public function removeProcess 	( processName : Class )			: void	 	{ }
	public function removeCommand		( commandName : String )		: void 		{ controller.removeCommand( commandName ); }
	public function removeMediator	( mediatorName : String ) 	: IMediator { return view.removeMediator( mediatorName ); }
	//========================================================================================================================================

	// IFacade
	//========================================================================================================================================
	public function sendNotification 	( notification:INotification )	: void 		{ view.notifyObservers( notification ); }
	public function executeCommand 		( notification:INotification )	: void 		{ controller.executeCommand( notification ); }
	public function runProcess 			  ( notification:INotification )	: void 		{  }
	//========================================================================================================================================
}
}
