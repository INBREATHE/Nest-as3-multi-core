/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.dialog
{
public class NativeDialogNotification
{
	static public const
		DATEPICKER		:String = "nest_note_nativedialog_datepicker"			// Displays a native date-picker dialog.
	,	PICKER			:String = "nest_note_nativedialog_picker"				// Displays a dialog with a scrollable list. On IOS - the native picker
	,	LIST			:String	= "nest_note_nativedialog_list"					// Displays a native popup dialog with a multi-choice or single-choice list.
	,	ALERT			:String = "nest_note_nativedialog_alert"				// Displays a native alert dialog.
	,	INPUT			:String = "nest_note_nativedialog_input"				// Displays a dialog with defined text-fields..
	,	TOAST			:String = "nest_note_nativedialog_toast"				// Displays a dialog with defined text-fields..
	,	PROGRESS		:String = "nest_note_nativedialog_progress"				// Displays a progress dialog.
	;
}
}