/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.dialog
{
import nest.interfaces.IMediator;
import nest.interfaces.INotification;
import nest.patterns.mediator.Mediator;

/**
 * A Mediator for interacting with the dialogs
 */
public class NativeDialogsMediator extends Mediator implements IMediator
{
	public static const NAME:String = "DialogsMediator";
	public function NativeDialogsMediator() { super( null ); }

	override public function listNotificationInterests():Vector.<String>
	{
		return new <String>[
			NativeDialogNotification.ALERT
		,	NativeDialogNotification.DATEPICKER
		,	NativeDialogNotification.INPUT
		,	NativeDialogNotification.LIST
		,	NativeDialogNotification.PICKER
		,	NativeDialogNotification.PROGRESS
		,	NativeDialogNotification.TOAST
		];
	}

	override public function handleNotification( note:INotification ):void
	{
		var name:String = note.getName();
		switch ( name )
		{
			case NativeDialogNotification.DATEPICKER:

			break;
			case NativeDialogNotification.PICKER:

			break;
			case NativeDialogNotification.LIST:

			break;
			case NativeDialogNotification.ALERT:

			break;
			case NativeDialogNotification.INPUT:

			break;
			case NativeDialogNotification.TOAST:
				trace(String(note.getBody()));
			break;
			case NativeDialogNotification.PROGRESS:

			break;
		}
	}
	//==================================================================================================
	override public function onRegister():void {
	//==================================================================================================

	}
}
}
