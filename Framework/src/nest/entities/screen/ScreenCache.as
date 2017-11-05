/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.screen
{
public class ScreenCache
{
	public var screen:Screen;
	public var mediatorName:String;
	public var prevScreenCache:ScreenCache;

	public function ScreenCache(screen:Screen, mediatorName:String )
	{
		this.screen = screen;
		this.mediatorName = mediatorName;
	}

	public function get name():String {
		return this.screen.name;
	}
}
}
