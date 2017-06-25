/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.scroller
{
import nest.interfaces.IMediator;
import nest.interfaces.INotification;
import nest.patterns.mediator.Mediator;

/**
 * A Mediator for interacting with the scroller
 */
public class ScrollerMediator extends Mediator implements IMediator
{
	public function ScrollerMediator( ) { super(new Scroller()); }
	override public function listNotificationInterests():Vector.<String> {
		return new <String>[
			ScrollerNotifications.SETUP_SCROLLER,
			ScrollerNotifications.RESET_SCROLLER
		];
	}

	override public function handleNotification( note:INotification ):void {
//		trace("> Nest -> ScrollerMediator > Notification:", note.getName())
		switch ( note.getName() ) {
			case ScrollerNotifications.SETUP_SCROLLER:
				scroller.setup(note.getBody());
				break;
			case ScrollerNotifications.RESET_SCROLLER:
				scroller.reset();
				break;
		}
	}

	private function get scroller():Scroller { return Scroller(this.viewComponent); }
}
}
