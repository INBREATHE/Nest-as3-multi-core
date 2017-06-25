/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.cache.entities
{
public class CacheReport
{
	private var _name : String;
	public function get name():String { return _name; }

	private var _time		: uint;
	public function get time():uint { return _time; }

	private var _params	: Object;
	public function get params():Object { return _params; }

	public function CacheReport(name:String, time:uint, params:Object):void {
		this._params = params;
		this._time = time;
		this._name = name;
	}
}
}