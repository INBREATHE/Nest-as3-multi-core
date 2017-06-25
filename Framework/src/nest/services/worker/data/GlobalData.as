/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.worker.data
{
public class GlobalData {

	private static var _instances : Object = { };
	private var DATA : Object = { };

	public function GlobalData($blocker:SingletonBlocker)
	{
		if ( $blocker == null )  {
			throw new Error( "Public construction not allowed.  Use getInstance()" );
		}
	}
	public static function getInstance (key:String) : Object {
		if (!(key in _instances)) _instances[key] = new GlobalData( new SingletonBlocker() );
		return _instances[key].DATA;
	}
	public static function killInstance (key:String) : void {
		var id:String = "";
		for (id in _instances[key].data)
			delete _instances[key].data[id];
		delete _instances[key];
	}
}
}

class SingletonBlocker
{

}