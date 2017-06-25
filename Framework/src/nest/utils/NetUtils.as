/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.utils
{
import flash.net.InterfaceAddress;
import flash.net.NetworkInfo;
import flash.net.NetworkInterface;

public class NetUtils
{
	static public function globalIP():String{
		return getIP(0);
	}
	static public function localIP():String{
		return getIP(1);
	}

	static private function getIP(index:uint, log:Boolean = false):String {
		const netInterfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
		var addresses:Vector.<InterfaceAddress>;
		if(log) netInterfaces.every(function(ni:NetworkInterface):void {
			trace("> Nest -> NetworkInterface:", ni.addresses);
			addresses = ni.addresses;
			addresses.forEach(function(ia:InterfaceAddress, i:uint, vec1:Vector.<InterfaceAddress>):void {
				trace("> \tInterfaceAddress:", i, ia.address);
			});
		});
		addresses = netInterfaces[index].addresses;
		return addresses[0].address;
	}
}
}