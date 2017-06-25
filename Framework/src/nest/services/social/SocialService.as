/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.social
{
import flash.events.EventDispatcher;

import nest.interfaces.IService;

public final class SocialService extends EventDispatcher implements IService
{
	public function init(data:Object):void {

	}

	private static const _instance:SocialService = new SocialService();
	public function SocialService() { if(_instance != null) throw new Error("This is a singleton class, use .getInstance()"); }
	public static function getInstance():SocialService { return _instance; }
}
}