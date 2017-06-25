/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.server.entities
{
public final class ServerProcess implements IServerData
{
	private var _path:String;
	public function get path():String { return _path; }

	private var _data:Object;
	public function get data():Object { return _data; }

	private var _callback:Object;
	public function get callback():Object {	return _callback; }

	/**
	 * Мы отправляем на сервер на какой то запрос path с данными data
	 * callback может быть Notification, Command или Function
	 * он проверяется в ServerResponceCommand
	 */
	public function ServerProcess(path:String, data:Object, callback:Object)
	{
		this._callback = callback;
		this._data = data;
		this._path = path;
	}
}
}