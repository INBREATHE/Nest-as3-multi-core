/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker
{
public final class WorkerMessageResponce
{
	private var _responce:*;
	private var _pipeID:uint;

	public function WorkerMessageResponce(responce:*, pipeID)
	{
		this._responce = responce;
		this._pipeID = pipeID;
	}
	public function getResponce():* { return _responce; }
	public function getPipeID():uint { return _pipeID; }
}
}