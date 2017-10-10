/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.application
{
public final class ApplicationNotification
{
	private static const PREFIX:String = "note_nest_application_";
	static public const
		PREPARE					: String = PREFIX + "prepare"
	,	VIEW_READY				: String = PREFIX + "initialized"
	,	INITIALIZED				: String = PREFIX + "initialized"
	,	SHOW_SCREEN				: String = PREFIX + "showscreen"
	,	HIDE_SCREEN				: String = PREFIX + "hidescreen"
	,	ADD_ELEMENT				: String = PREFIX + "addelement"
	,	REMOVE_ELEMENT			: String = PREFIX + "removeelement"
	,	LANGUAGE_CHANGED		: String = PREFIX + "language_changed"

	,	POPUP_CLOSED			: String = PREFIX + "popupclosed"
	,	POPUP_OPENED			: String = PREFIX + "popupopened"
	,	ANDROID_BACK_BUTTON		: String = PREFIX + "androidbackbutton"
	;
}
}