/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.popup
{
public final class PopupNotification
{
	static public const
		SHOW_POPUP			: String = "nest_note_popup_show"
	,	SHOW_POPUP_BY_NAME	: String = "nest_note_popup_show_by_name"
	,	HIDE_POPUP			: String = "nest_note_popup_hide"
	,	HIDE_ALL_POPUPS		: String = "nest_note_popup_hide_all"
	,	UNLOCK_POPUP		: String = "nest_note_popup_unlock"
	,	UPDATE_POPUP		: String = "nest_note_popup_update"
	,	REGISTER_POPUP		: String = "nest_note_popup_register"
	;
}
}