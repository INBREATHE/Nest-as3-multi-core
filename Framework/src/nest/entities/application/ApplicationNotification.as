/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.application
{
public final class ApplicationNotification
{
	static public const
		PREPARE						: String = "note_nest_application_prepare"
	,	INITIALIZED					: String = "note_nest_application_initialized"
	,	SHOW_SCREEN					: String = "note_nest_application_showscreen"
	,	HIDE_SCREEN					: String = "note_nest_application_hidescreen"
	,	ADD_ELEMENT					: String = "note_nest_application_addelement"
	,	REMOVE_ELEMENT				: String = "note_nest_application_removeelement"
	,	LANGUAGE_CHANGED			: String = "note_nest_application_language_changed"

	,	POPUP_CLOSED				: String = "note_nest_application_popupclosed"
	,	POPUP_OPENED				: String = "note_nest_application_popupopened"
	,	ANDROID_BACK_BUTTON			: String = "note_nest_application_androidbackbutton"
	;
}
}