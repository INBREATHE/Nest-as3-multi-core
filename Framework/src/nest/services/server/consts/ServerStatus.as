/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.server.consts
{
public final class ServerStatus
{
	static private const STATUS	: String = "status";

	static public const OK		: String = "ok";
	static public const ERROR	: String = "error";

	static public function EXIST(data:Object):Boolean {
		return data.hasOwnProperty(STATUS) && data[STATUS] == OK;
	}

	static public function ALLOW(data:Object):Boolean {
		return data != null && EXIST(data);
	}
}
}