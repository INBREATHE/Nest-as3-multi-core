package nest.patterns.command.body {

public class CallbackCommandData {

	private var _OnComplete:Function;
	private var _OnSuccess:Function;
	private var _OnError:Function;

	private var _body:Object;

	public function CallbackCommandData( body:Object ) {
		_body = body;
	}

	public function onComplete( func:Function ):CallbackCommandData {
		_OnComplete = func;
		return this;
	}

	public function onError( func:Function ):CallbackCommandData {
		_OnError = func;
		return this;
	}

	public function onSuccess( func:Function ):CallbackCommandData {
		_OnSuccess = func;
		return this;
	}

	public function get body():Object {
		return _body;
	}

	public function get OnComplete():Function { return _OnComplete; }
	public function get OnSuccess():Function { return _OnSuccess; }
	public function get OnError():Function { return _OnError; }

	public function dispose():void {
		_OnComplete = null;
		_OnSuccess = null;
		_OnError = null;
		_body = null;
	}
}
}
