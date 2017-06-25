/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.core
{
import flash.utils.Dictionary;

import nest.injector.Injector;
import nest.interfaces.IModel;
import nest.interfaces.IProxy;

public class Model implements IModel
{
	// Message Constants
	static private const MULTITON_MSG:String = "Model instance for this Multiton key already constructed!";
	static private const instanceMap:Dictionary = new Dictionary();

	protected var multitonKey : String;
	protected const proxyMap : Dictionary = new Dictionary();

	public function Model( key:String ) {
		if (instanceMap[ key ] != null) throw Error(MULTITON_MSG);
		multitonKey = key;
		instanceMap[ multitonKey ] = this;
		initializeModel();
	}

	protected function initializeModel() : void { }

	//==================================================================================================
	public static function getInstance( key:String ) : IModel {
	//==================================================================================================
		var instance:Model = instanceMap[ key ];
		if ( instance == null ) instance = new Model(key);
		return instance;
	}

	//==================================================================================================
	public function registerProxy( proxyClass:Class ) : void {
	//==================================================================================================
		const proxy		:IProxy = new proxyClass();
		const proxyName	:String = proxy.getProxyName();
		proxy.initializeNotifier( multitonKey );
		Injector.mapSource( proxyName, proxy );
		proxyMap[ proxyName ] = proxy;
		proxy.onRegister();
	}

	public function retrieveProxy( proxyName:String ) : IProxy { return proxyMap[ proxyName ]; }
	public function hasProxy( proxyName:String ) : Boolean { return proxyMap[ proxyName ] != null; }

	//==================================================================================================
	public function removeProxy( proxyName:String ) : IProxy {
	//==================================================================================================
		const proxy:IProxy = proxyMap [ proxyName ] as IProxy;
		if ( proxy ) {
			delete proxyMap[ proxyName ];
			proxy.onRemove();
		}
		return proxy;
	}

	//==================================================================================================
	public static function removeModel( key:String ):void {
	//==================================================================================================
		delete instanceMap[ key ];
	}
}
}
