/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.worker.process.messages
{
[RemoteClass]
public final class CallWorkerMessage
{
	private var
		_id			: int
	,	_method		: String
	,	_args		: Array

	,	_onComplete	: Boolean
	,	_onProgress	: Boolean
	,	_onError	: Boolean
	;

	public function CallWorkerMessage(
		id			: int = 0,
		method		: String = "",
		args		: Array = null,
		onComplete	: Boolean = false,
		onProgress	: Boolean = false,
		onError		: Boolean = false
	) {
		this._onError = onError;
		this._onProgress = onProgress;
		this._onComplete = onComplete;
		this._args = args;
		this._method = method;
		this._id = id;
	}

	public function get id():int
	{
		return _id;
	}

	public function get method():String
	{
		return _method;
	}

	public function get args():Array
	{
		return _args;
	}

	public function get onComplete():Boolean
	{
		return _onComplete;
	}

	public function get onProgress():Boolean
	{
		return _onProgress;
	}

	public function get onError():Boolean
	{
		return _onError;
	}

	public function set id(value:int):void { _id = value; }

	public function set method(value:String):void { _method = value; }

	public function set args(value:Array):void { _args = value; }

	public function set onComplete(value:Boolean):void { _onComplete = value; }

	public function set onProgress(value:Boolean):void { _onProgress = value; }

	public function set onError(value:Boolean):void { _onError = value; }
}
}