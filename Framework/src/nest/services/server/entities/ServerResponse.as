/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.server.entities
{
import flash.events.Event;
import nest.services.server.consts.ServerStatus;

public final class ServerResponse extends Event implements IServerData
{
	public static const COMPLETE:String = "nest_server_service_request_complete";

	private var _data:Object;
	private var _callback:Object;

	public function get data():Object { return _data; }
	public function get callback():Object {	return _callback; }

	public function ServerResponse( callback:Object, data:Object )
	{
		this._callback = callback;
		this._data = data;
		super(COMPLETE, false, false);
	}

	public static function CREATE_NO_NETWORK_RESPONSE(callback:Object):IServerData {
		// TODO: Create special response value object
		return new ServerResponse(callback, { status: ServerStatus.ERROR, message: "No network connection" });
	}
}
}