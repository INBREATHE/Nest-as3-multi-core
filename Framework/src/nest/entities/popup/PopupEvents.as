/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.popup
{
public final class PopupEvents
{
	private static const PREFIX:String = "event_popup_";
	static public const 
		COMMAND_FROM_POPUP		: String = PREFIX + "commandFromPopup"
	,	TAP_HAPPEND_OK			: String = PREFIX + "tapHappendOk"
	,	TAP_HAPPEND_CLOSE		: String = PREFIX + "tapHappendClose"
	, 	POPUP_SHOWN				: String = PREFIX + "popup_shown"
	;

}
}