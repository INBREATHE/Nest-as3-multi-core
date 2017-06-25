/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.worker.interfaces
{
public interface IWorkerFactory
{
	function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;
	function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
	function call(method:String, args:Array = null, onComplete:Function = null, onProgress:Function = null, onError:Function = null) : Boolean;
	function get isPrimordial():Boolean;
	function get hasWorker() : Boolean;
	function get singleThreadMode() : Boolean;
	function set singleThreadMode(value:Boolean) : void;
	function destroy(callback:Function = null) : void;
}
}