/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.patterns.proxy
{
import flash.utils.getQualifiedClassName;

import nest.interfaces.IProxy;
import nest.patterns.observer.Notifier;

public class Proxy extends Notifier implements IProxy
{
	protected var proxyName:String;
	protected var data:Object;

	public function Proxy( data:Object = null ) {
		proxyName = getQualifiedClassName( this );
		if ( data != null ) setData( data );
	}

	public function getProxyName():String { return proxyName; }
	public function setData( data:Object ):void { this.data = data; }
	public function getData():Object { return data; }

	public function onRegister():void {}
	public function onRemove():void {}
}
}