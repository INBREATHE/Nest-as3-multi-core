/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.utils
{
public final class TimeUtils
{

	//
	// Milliseconds
	//

	public static const YEAR_IN_MILLISECONDS:Number = 31536000000.0;

	public static const THIRTY_ONE_DAY_MONTH_IN_MILLISECONDS:Number = 2678400000.0;

	public static const THIRTY_DAY_MONTH_IN_MILLISECONDS:Number = 2592000000.0;

	public static const TWENTY_EIGHT_DAY_MONTH_IN_MILLISECONDS:Number = 2419200000.0;

	public static const WEEK_IN_MILLISECONDS:Number = 604800000.0;

	public static const DAY_IN_MILLISECONDS:Number = 86400000.0;

	public static const HOUR_IN_MILLISECONDS:Number = 3600000.0;

	public static const MINUTE_IN_MILLISECONDS:Number = 60000.0;


	//
	// Seconds
	//

	public static const YEAR_IN_SECONDS:Number = 31536000;

	public static const THIRTY_ONE_DAY_MONTH_IN_SECONDS:Number = 2678400;

	public static const THIRTY_DAY_MONTH_IN_SECONDS:Number = 2592000;

	public static const TWENTY_EIGHT_DAY_MONTH_IN_SECONDS:Number = 2419200;

	public static const WEEK_IN_SECONDS:Number = 604800;

	public static const DAY_IN_SECONDS:Number = 86400;

	public static const HOUR_IN_SECONDS:Number = 3600;

	public static const MINUTE_IN_SECONDS:Number = 60;

	private static const TIMECODE:Array = ["days", "hours", "minutes", "seconds"];
	public static function timeCode(sec:uint, devider:Number = 0.001):String {
		sec = sec * devider;
		const his:uint = sec % HOUR_IN_SECONDS;
		const d:uint = Math.floor(sec / DAY_IN_SECONDS);
		const h:uint = Math.floor(sec / HOUR_IN_SECONDS);
		const m:uint = Math.floor(his / MINUTE_IN_SECONDS);
		const s:uint = Math.ceil(his % MINUTE_IN_SECONDS);

		TIMECODE[0] = d == 0 ? "" : String(d) + ":";
		TIMECODE[1] = h == 0 ? "" : ((h < 10 ? "0" + String(h) : String(h)) + ":");
		TIMECODE[2] = (m < 10 ? "0" + String(m) : String(m)) + ":";
		TIMECODE[3] = s < 10 ? "0" + String(s) : String(s);
		return TIMECODE.join("");
	}
}
}