package nest.entities.popup
{
	public final class PopupData
	{
		private var 
			_data			      : Object
		,	_onPopupAdded	  : Function
		,	_onPopupRemoved	: Function
		,	_onPopupShown	  : Function
		;
		
		public function PopupData(data:Object = null)
		{
			_data = data;
		}
		
		public function onPopupAdded(callback:Function):PopupData {
			_onPopupAdded = callback;
			return this;
		}
		
		public function onPopupShown(callback:Function):PopupData {
			_onPopupShown = callback;
			return this;
		}
		
		// This method will be called after popup was removed from the stage but only in case it's not forced to be removed
		public function onPopupRemoved(callback:Function):PopupData {
			_onPopupRemoved = callback;
			return this;
		}

		public function get data():Object { return _data; }
		public function set data(value:Object):void { _data = value; }

		public function get onAdded():Function { return _onPopupAdded; }
		public function get onRemoved():Function { return _onPopupRemoved; }
		public function get onShown():Function { return _onPopupShown; }


	}
}