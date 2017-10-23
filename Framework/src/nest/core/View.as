/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.core
{
import flash.utils.Dictionary;

import nest.injector.Injector;
import nest.interfaces.IMediator;
import nest.interfaces.INotification;
import nest.interfaces.IObserver;
import nest.interfaces.IView;
import nest.patterns.observer.NFunction;
import nest.patterns.observer.Observer;

public class View implements IView
{
	static private const MULTITON_MSG:String = "View instance for this Multiton key already constructed!";
	static private const instanceMap : Dictionary = new Dictionary();

	protected var multitonKey 		: String;
	protected var mediatorMap 		: Dictionary = new Dictionary();
	protected var observerMap		: Dictionary = new Dictionary();

	public function View( key:String ) {
		if (instanceMap[ key ] != null) throw Error(MULTITON_MSG);
		multitonKey = key;
		instanceMap[ multitonKey ] = this;
		initializeView();
	}

	//==================================================================================================
	public static function getInstance( key:String ) : IView {
	//==================================================================================================
		var instance:View = instanceMap[ key ];
		if(instance == null)  instance = new View( key );
		return instance;
	}

	//==================================================================================================
	public function registerObserver ( notificationName:String, observer:IObserver ) : void {
	//==================================================================================================
		const observers:Vector.<IObserver> = observerMap[ notificationName ];
//		trace("> Nest -> View > registerObserver: name =", notificationName);
		if( observers ) {
			observers.push( observer );
		} else {
			observerMap[ notificationName ] = new <IObserver>[ observer ];
		}
	}

	//==================================================================================================
	public function notifyObservers( notification:INotification ) : void {
	//==================================================================================================
		const notificationName:String = notification.getName();
		const observers:Vector.<IObserver> = observerMap[ notificationName ];
//		trace("> Nest -> View > notifyObservers: name =", notificationName);
//		trace("> Nest -> View > notifyObservers: observers =", observers);
		if( observers != null ) {
			observers.forEach(function(observer:IObserver, index:uint, vector:Vector.<IObserver>) : void {
				if(observer) observer.notifyObserver( notification );
			});
		}
	}

	//==================================================================================================
	public function registerMediator( mediator:IMediator ) : void {
	//==================================================================================================
		const mediatorName:String = mediator.getMediatorName();
		if ( mediatorMap[ mediatorName ] != null ) return;

		mediator.initializeNotifier( multitonKey );
		mediatorMap[ mediatorName ] = mediator;

		Injector.mapInject( mediator );

//		trace("\n> Nest -> View -> registerMediator:", mediatorName);
		
		const interests:Vector.<String> = mediator.listNotifications;
		var listCounter:uint = interests.length;
		var notificationName:String;
		if ( listCounter > 0 ) {
			const observer:Observer = new Observer( mediator.handleNotification, mediator );
			while(listCounter--) {
				notificationName = interests[listCounter];
				if(notificationName.length > 0) 
					registerObserver( notificationName , observer );
			}
		}
		mediator.onRegister();
	}

	//==================================================================================================
	public function registerMediatorAdvance( mediator:IMediator ) : void {
	//==================================================================================================
		const mediatorName:String = mediator.getMediatorName();
		if ( mediatorMap[ mediatorName ] != null ) return;

		mediator.initializeNotifier( multitonKey );
		mediatorMap[ mediatorName ] = mediator;

		Injector.mapInject( mediator );

		const interestsNotes:Vector.<String> 		= mediator.listNotifications;
		const interestsNFunc:Vector.<NFunction> 	= mediator.listNFunctions;

		var listCounter		: uint = interestsNFunc.length
		,	notifyMethod	: Function
		,	notifyContext	: Object
		,	notifyName		: String
		;

		const viewComponent:Object = mediator.getViewComponent();
		
//		trace("\n> Nest -> View -> registerMediatorAdvance:", mediatorName);
//		trace("> Nest -> View -> REGISTER NFunction");
		
		var observer:Observer;
		var nFunction:NFunction;
		if ( listCounter > 0 ) {
			var nFunctionType:String;
			var nFunctionFunc:Object;
			while(listCounter--) {
				nFunction = interestsNFunc[listCounter];
				notifyName = nFunction.name;
				nFunctionFunc = nFunction.func;
				nFunctionType = typeof nFunctionFunc;
				switch(nFunctionType) {
					case NFunction.TYPE_STRING:
						notifyContext = Object(viewComponent);
						notifyMethod = notifyContext[String(nFunctionFunc)] as Function;
						break;
					case NFunction.TYPE_FUNCTION:
						notifyMethod = nFunctionFunc as Function;
						notifyContext = mediator;
						break;
				}
				observer = new Observer( notifyMethod, notifyContext, true );
				registerObserver( notifyName, observer );
			}
		}
		
//		trace("> Nest -> View -> REGISTER Notifications");

		//REGISTER LIST NOTIFICATIONS
		listCounter = interestsNotes.length;
		if( listCounter > 0 ) {
			observer = new Observer( mediator.handleNotification, mediator );
			while( listCounter-- ){
				notifyName = interestsNotes[ listCounter ];
				if(notifyName.length > 0) registerObserver( notifyName,  observer );
			}
		}

		mediator.onRegister();
	}
	
	//==================================================================================================
	public function removeMediator( mediatorName:String ) : IMediator {
	//==================================================================================================
		const mediator:IMediator = mediatorMap[ mediatorName ] as IMediator;
//		trace("> Nest -> View > removeMediator: name =", mediatorName);
//		trace("> Nest -> View > removeMediator: mediator =", mediator);
		if ( mediator ) {
			const interestsNotes:Vector.<String> = mediator.listNotifications;
			var listCounter:uint = interestsNotes.length;
			var notificationName:String = "";
			while( listCounter-- ) {
				notificationName = interestsNotes[ listCounter ];
				removeObserver( notificationName , mediator );
			}
			
			const interestsNFunc:Vector.<NFunction> = mediator.listNFunctions;
			const viewComponent:Object = mediator.getViewComponent();
			
			listCounter = interestsNFunc.length;
			
			var nFunction:NFunction;
			var nContext:Object;
			var nFunctionType:String;
			while(listCounter--) {
				nFunction = interestsNFunc[listCounter];
				notificationName = nFunction.name;
				nFunctionType = typeof nFunction.func;
				switch(nFunctionType) {
					case NFunction.TYPE_STRING: nContext = viewComponent; break;
					case NFunction.TYPE_FUNCTION: nContext = mediator; break;
				}
				removeObserver( notificationName , nContext );
			}
			
			delete mediatorMap[ mediatorName ];
			mediator.onRemove();
		}
		return mediator;
	}

	//==================================================================================================
	protected function initializeView(  ) : void { }
	//==================================================================================================
	
	//==================================================================================================
	public function retrieveMediator( mediatorName:String ) : IMediator { return mediatorMap[ mediatorName ]; }
	public function hasMediator( mediatorName:String ) : Boolean { return mediatorMap[ mediatorName ] != null; }
	//==================================================================================================
	
	//==================================================================================================
	private function removeObserver( notificationName:String, notifyContext:Object ):void {
	//==================================================================================================
		const observers:Vector.<IObserver> = observerMap[ notificationName ] as Vector.<IObserver>;
		var count:uint = observers.length;
		var observer:IObserver;
		while(count--) {
			observer = IObserver(observers[ count ]);
			if ( observer.compareNotifyContext( notifyContext ) == true ) {
				observers.removeAt(count);
				break;
			}
		}

		if ( observers.length == 0 ) {
			delete observerMap[ notificationName ];
		}
	}

	//==================================================================================================
	public static function removeView( key:String ):void {
	//==================================================================================================
		delete instanceMap[ key ];
	}
}
}