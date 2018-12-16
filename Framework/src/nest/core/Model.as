/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.core
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import nest.injector.Injector;
	import nest.interfaces.IModel;
	import nest.interfaces.IProxy;
	import nest.patterns.proxy.Proxy;
	import nest.services.localization.LanguageDependentProxy;
	
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
		public function languageChanged() : void {
		//==================================================================================================
			var localizeProxy:Proxy;
			for each ( localizeProxy in proxyMap )
				if ( localizeProxy is LanguageDependentProxy )
					LanguageDependentProxy( localizeProxy ).languageChanged();
		}
	
		//==================================================================================================
		public function registerProxy( proxyClass:Class ) : void {
		//==================================================================================================
			const proxy		: IProxy = new proxyClass();
			const proxyName	: String = proxy.getProxyName(); // getQualifiedClassName inside Proxy constructor
			
			proxy.initializeNotifier( multitonKey );
			Injector.mapSource( proxyName, proxy );
			proxyMap[ proxyName ] = proxy;
			proxy.onRegister();
		}
	
		public function retrieveProxy( proxyClass:Class ) : IProxy { return proxyMap[ getQualifiedClassName(proxyClass) ]; }
		public function hasProxy( proxyClass:Class ) : Boolean { return proxyMap[ getQualifiedClassName(proxyClass) ] != null; }
	
		//==================================================================================================
		public function removeProxy( proxyClass:Class ) : IProxy {
		//==================================================================================================
			const proxyName:String = getQualifiedClassName(proxyClass);
			const proxy:IProxy = proxyMap [ proxyName ] as IProxy;
			if ( proxy ) {
				delete proxyMap[ proxyName ];
				proxy.onRemove();
			}
			return proxy;
		}
	
		//==================================================================================================
		public static function removeModel( key:String ):void { delete instanceMap[ key ]; }
		//==================================================================================================
	}
}
