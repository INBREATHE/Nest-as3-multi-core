package nest.entities.screen
{
	public final class ScreenData
	{
		public function hasContentReadyCallback():Boolean { return _contentReadyCallback != null; }
		public function get contentReadyCallback():Function { return _contentReadyCallback; }
		public function get data():Object { return _data; }

		private var 
			_contentReadyCallback:Function
			
		,	_previous	  : Boolean
		,	_fromScreen	: String
		,	_toScreen	  : String
		,	_data		    : Object
		;
		
		public function ScreenData( data:Object = null ) {
			_data = data;
		}

		public function onContentReady( callback:Function ):ScreenData {
			_contentReadyCallback = callback;
			return this;
		}
		
		public function get toScreen():String { return _toScreen; }
		public function set toScreen(value:String):void { _toScreen = value; }

		public function get fromScreen():String {
			return _fromScreen;
		}

		public function set fromScreen(value:String):void {
			_fromScreen = value;
		}

		public function get previous():Boolean {
			return _previous;
		}

		public function set previous(value:Boolean):void {
			_previous = value;
		}
	}
}