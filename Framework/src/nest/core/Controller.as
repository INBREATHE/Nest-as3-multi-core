/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.core
{
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;

import nest.injector.Injector;
import nest.interfaces.ICommand;
import nest.interfaces.ICommand;
import nest.interfaces.IController;
import nest.interfaces.INotification;

public class Controller implements IController
{
	static protected const instanceMap : Dictionary = new Dictionary();
	static private const MULTITON_MSG : String = "Controller instance for this Multiton key already constructed!";

	private const _commandMap 		: Dictionary = new Dictionary();
	private const _replyCountMap 	: Dictionary = new Dictionary();

	private var _multitonKey : String = "";

	public function Controller( key:String ) {
		const instance:Controller = instanceMap[ key ];
		if (instance != null) throw Error(MULTITON_MSG);
		_multitonKey = key;
		instanceMap[ _multitonKey ] = this;
		initializeController();
	}

	protected function initializeController() : void { }

	//==================================================================================================
	public static function getInstance(key:String) : IController {
	//==================================================================================================
		var instance:Controller = instanceMap[ key ];
		if ( instance == null ) instance = new Controller(key);
		return instance;
	}

	//==================================================================================================
	public function executeCommand( note : INotification ) : void {
	//==================================================================================================
		const commandName 	: String 	= note.getName();
		const commandBody 	: Object 	= note.getBody();
		const commandType 	: String 	= note.getType();

		var commandInstance : Object = _commandMap[ commandName ];
		if( commandInstance is Class ) {
			const commandClassRef : Class = commandInstance as Class;
			commandInstance = new commandClassRef();
//			trace("> Nest -> ", multitonKey, "> executeCommand : commandInstance", commandInstance);
			commandInstance.initializeNotifier( _multitonKey );
//			trace("> Nest -> ", multitonKey, "> Injector.hasTarget", commandClassRef);
			if(Injector.hasTarget(commandClassRef, _multitonKey)) {
				Injector.injectTo(commandClassRef, ICommand(commandInstance) );
			}
		}

		if( commandInstance )
		{
			var replyCount:int = _replyCountMap[ commandName ];
//			trace("> Nest -> executeCommand :", commandName, commandInstance, "replyCount = " + replyCount);
			if(replyCount) {
				replyCount = replyCount - 1;
				if(replyCount == 0) {
					delete _replyCountMap[ commandName ];
					removeCommand( commandName );
				} else {
					_replyCountMap[ commandName ] = replyCount;
				}
			}
			commandInstance.execute( commandBody, commandType );
//			if(commandInstance is PromiseCommand) {
//				return PromiseCommand(commandInstance).promise;
//			}
		}
		else {
			trace("> Nest > Command does not exist: " + commandName);
		}
	}

	//==================================================================================================
	public function registerCommand( commandClassName : String, commandClassRef : Class ) : void {
	//==================================================================================================
//		trace("> Nest -> ", _multitonKey, "> registerCommand : commandClassName", commandClassName);
		Injector.mapTarget( commandClassRef, _multitonKey );
		_commandMap[ commandClassName ] = commandClassRef;
	}

	//==================================================================================================
	public function registerPoolCommand( commandClassName : String, commandClassRef : Class ):void {
	//==================================================================================================
		const commandInstance:ICommand = new commandClassRef();
		commandInstance.initializeNotifier( _multitonKey );
		Injector.mapInject( commandInstance );
//		trace("registerPoolCommand", commandClassRef);
		_commandMap[ commandClassName ] = commandInstance;
	}

	//==================================================================================================
	public function registerCountCommand( commandClassName : String, commandClassRef : Class, replyCount:int ) : void {
	//==================================================================================================
		if(replyCount < 0) registerPoolCommand( commandClassName, commandClassRef );
		else {
			if(replyCount > 0) _replyCountMap[ commandClassName ] = replyCount;
			registerCommand( commandClassName, commandClassRef );
		}
	}

	//==================================================================================================
	public function registerPromiseCommand( notificationName : String, commandClassRef : Class ):void {
	//==================================================================================================

	}

	//==================================================================================================
	public function hasCommand( commandName : String ) : Boolean {
	//==================================================================================================
		return _commandMap[commandName] != null;
	}

	//==================================================================================================
	public function removeCommand( commandName : String ) : Boolean {
	//==================================================================================================
		const commandClassRef:Class = _commandMap[ commandName ];
		if ( commandClassRef ) {
			Injector.unmapTarget( commandClassRef, _multitonKey );
			delete _commandMap[ commandName ];
			return true;
		}
		return false;
	}

	//==================================================================================================
	public static function removeController( key:String ):void {
	//==================================================================================================
		delete instanceMap[ key ];
	}
}
}