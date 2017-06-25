/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.worker.process
{
public class WorkerHandler
{
	private var
	_id				:int
	,	_onComplete		:Function
	,	_onProgress		:Function
	,	_onError		:Function
	;

	private var _single:Boolean;

	public function WorkerHandler(id:int, onComplete:Function, onProgress:Function, onError:Function, single:Boolean = true)
	{
		this._single = single;
		this._onError = onError;
		this._onProgress = onProgress;
		this._onComplete = onComplete;
		this._id = id;
	}

	public function get id():int { return _id; }
	public function get onComplete():Function {	return _onComplete;	}
	public function get onProgress():Function { return _onProgress; }
	public function get onError():Function { return _onError; }
}
}

