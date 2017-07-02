/**
 * Created by DQvsRA on 02.07.2017.
 */
package nest.services.network {
import flash.events.Event;

public class NetworkStatusEvent extends Event
{
    private var _available:Boolean;
    public function get available():Boolean { return _available; }

    public function NetworkStatusEvent(name:String, available:Boolean) {
        super(name, false, true);
        _available = available;
    }
}
}
