package nest.entities.popup {
public class PopupAction
{
	static private const PREFIX:String = "common_popup_action_";

	public static const COMMON_ACTION_ON_CLOSE:String = PREFIX + "on_close";

	private var _id:String;
	private var _name:String;
	private var _data:PopupActionData;

	public function PopupAction( id:String, name:String, data:PopupActionData = null ) {
		_id = id;
		_name = name;
		_data = data;
	}

	public function get name():String {
		return _name;
	}

	public function get data():PopupActionData {
		return _data;
	}

	public function get id():String {
		return _id;
	}

	public function setData( value:PopupActionData ):PopupAction {
		_data = value;
		return this;
	}
}
}
