/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.network
{
import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.net.NetworkInfo;
import flash.utils.getDefinitionByName;

import nest.interfaces.IService;

import starling.events.EventDispatcher;

public final class NetworkService extends EventDispatcher implements IService
{
	public static const
		NETWORK_CHANGED:String = "nest_network_service_network_changed"
	;

	private var _isNetworkAvailable:Boolean = false;

	public function init(app:Object):void
	{
		_isNetworkAvailable = CheckInternetConnection();
		NativeApplication.nativeApplication.addEventListener(Event.NETWORK_CHANGE, HandleNetworkChange);
	}

	//==================================================================================================
	public function get isNetworkAvailable():Boolean { return _isNetworkAvailable; }
	//==================================================================================================

	//==================================================================================================
	private function CheckInternetConnection():Boolean {
	//==================================================================================================
		var networkInterfaces:Object;

		if (flash.net.NetworkInfo.isSupported) {
			networkInterfaces = getDefinitionByName('flash.net.NetworkInfo')['networkInfo']['findInterfaces']();
			for each (var ni:Object in networkInterfaces) if (ni.active) return true;
		}

		return false;
	}

	//==================================================================================================
	private function HandleNetworkChange(event:Event):void {
	//==================================================================================================
		const previousState:Boolean = _isNetworkAvailable;
		_isNetworkAvailable = CheckInternetConnection();
		const status:Boolean = (previousState == false) && (_isNetworkAvailable == true);
		this.dispatchEventWith(NETWORK_CHANGED, false, status);
	}

	private static const _instance:NetworkService = new NetworkService();
	public function NetworkService() { if(_instance != null) throw new Error("This is a singleton class, use .getInstance()"); }
	public static function getInstance():NetworkService { return _instance; }
}
}