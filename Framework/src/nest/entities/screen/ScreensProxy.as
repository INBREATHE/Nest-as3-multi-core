/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.screen
{
import flash.utils.Dictionary;

import nest.interfaces.IProxy;
import nest.patterns.proxy.Proxy;

public class ScreensProxy extends Proxy implements IProxy
{
	private var _currentScreen:ScreenCache;

	public function ScreensProxy() { super(new Dictionary()); }

	//==================================================================================================
	public function cacheScreenByName(name:String, value:ScreenCache):void {
	//==================================================================================================
		cache[name] = value;
	}

	//==================================================================================================
	public function getCacheByScreenName(value:String):ScreenCache {
	//==================================================================================================
		return cache[value] as ScreenCache;
	}

	//==================================================================================================
	public function getScreenByName(value:String):Screen {
	//==================================================================================================
		return this.getCacheByScreenName(value).screen;
	}

	private function get cache():Dictionary { return Dictionary(data); }

	//==================================================================================================
	public function set currentScreen(value:ScreenCache):void	{ _currentScreen = value; 		}
	public function get currentScreen():ScreenCache 			{ return _currentScreen; 		}
	public function get currentScreenName():String				{ return _currentScreen.name; 	}
	//==================================================================================================
}
}
