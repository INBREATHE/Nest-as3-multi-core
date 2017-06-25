/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.network
{
import nest.patterns.proxy.Proxy;

public class NetworkProxy extends Proxy
{
	private var
		_networkEnabledCommand		: String
	,	_networkDisabledCommand		: String
	;

	public function set networkEnabledCommand	(value:String):void { _networkEnabledCommand = value; }
	public function set networkDisabledCommand	(value:String):void { _networkDisabledCommand = value; }

	public function NetworkProxy() {
		super(NetworkService.getInstance());
		network.addEventListener(NetworkService.NETWORK_CHANGED, HandleNetworkChange);
	}

	public function get isNetworkAvailable():Boolean { return network.isNetworkAvailable; }

	//==================================================================================================
	private function HandleNetworkChange(event:Object, status:Boolean):void {
	//==================================================================================================
		trace("> Nest -> HandleNetworkChange :", status);
		var command:String = _networkDisabledCommand;
		if(status) command = _networkEnabledCommand;
		if(command != null) this.exec( command );
	}

	private function get network():NetworkService { return NetworkService(data); }
}
}