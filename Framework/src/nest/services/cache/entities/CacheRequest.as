/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.cache.entities
{
public final class CacheRequest
{
	private var _method:String;
	public function get method():String { return _method; }

	private var _data:Object;
	public function get data():Object { return _data; }

	private var _type:String;
	public function get type():String { return _type; }

	/**
	 * Этот объект сохраняется в ELS
	 * @name - имя функции которая вызывается в ServerProxy
	 * @data
	 */
	public function CacheRequest(type:String, method:String, data:Object)
	{
		this._type = type;
		this._data = data;
		this._method = method;
	}
}
}