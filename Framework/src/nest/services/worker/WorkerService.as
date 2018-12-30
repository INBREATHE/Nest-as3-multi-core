/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.worker
{
	/**
	 * 
	 * version 0.8.1
	*/

import flash.display.Sprite;
import flash.events.Event;
import flash.net.registerClassAlias;
import flash.system.Capabilities;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.system.WorkerState;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import nest.services.worker.events.WorkerEvent;
import nest.services.worker.interfaces.IWorkerFactory;
import nest.services.worker.process.WorkerHandler;
import nest.services.worker.process.WorkerTask;
import nest.services.worker.process.messages.CallWorkerMessage;
import nest.services.worker.process.messages.DataWorkerMessage;
import nest.services.worker.process.messages.EventWorkerMessage;

dynamic public class WorkerService extends Sprite implements IWorkerFactory
{
	public static const
		NAME	: String = "WorkerFactory";

	private static const
		INCOMIMG_MESSAGE	: String = "incomingMessage"
	,	OUTGOING_MESSAGE	: String = "outgoingMessage"
	,	SHARED_DATA_PIPE	: String = "sharedDataPipe"
	;

	private var
		__incomingMessageChannel:MessageChannel
	,	__outgoingMessageChannel:MessageChannel
	;

	private var
		__workerHandler 	: Dictionary
	,	__workerHandlerID 	: uint = 0
	,	__process 			: Object
	,	__tasklist 			: Vector.<WorkerTask> = new Vector.<WorkerTask>()
	,	__isReady 			: Boolean
	,	__DATA 				: Dictionary
	,	__singleThreadMode 	: Boolean = false
	,	__isPrimordial 		: Boolean
	;

	protected var __worker:Worker;
	protected var __sharable:ByteArray = new ByteArray();

	{
		registerClassAlias(getQualifiedClassName(CallWorkerMessage), CallWorkerMessage);
		registerClassAlias(getQualifiedClassName(DataWorkerMessage), DataWorkerMessage);
		registerClassAlias(getQualifiedClassName(EventWorkerMessage), EventWorkerMessage);
	}

	public function WorkerService(loaderBytes:ByteArray = null, giveAppPrivileges:Boolean = false) {
		if(Worker.isSupported) {
			if (Worker.current.isPrimordial) {
				if (loaderBytes == null) {
					error('loader is required!');
					return;
				}
				__isPrimordial = true;
				const className : String = getQualifiedClassName(this);
				var swf:ByteArray = loaderBytes;

				__worker = WorkerDomain.current.createWorker(swf, false);

				__incomingMessageChannel = Worker.current.createMessageChannel(__worker);
				__outgoingMessageChannel = __worker.createMessageChannel(Worker.current);

				__worker.setSharedProperty(INCOMIMG_MESSAGE, __incomingMessageChannel);
				__worker.setSharedProperty(OUTGOING_MESSAGE, __outgoingMessageChannel);

				__sharable.shareable = true;
				__worker.setSharedProperty(SHARED_DATA_PIPE, __sharable);

				__outgoingMessageChannel.addEventListener(Event.CHANNEL_MESSAGE, OnMessageReceived);
				__worker.addEventListener(Event.WORKER_STATE, OnWorkerStateHandler);
				__worker.start();

			} else {
				__isPrimordial = false;
				__worker = Worker.current;

				__incomingMessageChannel = __worker.getSharedProperty(INCOMIMG_MESSAGE);
				__outgoingMessageChannel = __worker.getSharedProperty(OUTGOING_MESSAGE);

				__sharable = __worker.getSharedProperty(SHARED_DATA_PIPE);
				__sharable.shareable = true;

				__incomingMessageChannel.addEventListener(Event.CHANNEL_MESSAGE, OnMessageReceived);

				__isReady = true;
			}
		} else {
			__isPrimordial = true;
		}
		Reset();
	}

	public final function get hasWorker() 			: Boolean { return __worker ? true : false; }
	public final function get isPrimordial() 		: Boolean { return (!__worker ? true : __isPrimordial);	}
	public final function get singleThreadMode() 	: Boolean { return __singleThreadMode;	}

	public final function set singleThreadMode(value:Boolean) : void {
		__singleThreadMode = value;
		if (hasEventListener(WorkerEvent.MODE_CHANGED)) {
			dispatchEvent(new Event(WorkerEvent.MODE_CHANGED));
		}
		if (value && !__isReady) {
			__isReady = true;
			if (hasEventListener(WorkerEvent.RUNNING)) {
				dispatchEvent(new Event(WorkerEvent.RUNNING));
			}
		}
	}

	private final function Reset():void {
		__isReady 		= false;
		__process 		= { };
		__workerHandler = new Dictionary(true);
		__DATA			= new Dictionary(true);
	}

	/**
	 * Calling a function on the other side, if you calling from main it will call function on worker, vice versa
	 *
	 * @param method The function name to be called.
	 * @param args The function parameters to be passed.
	 * @param onComplete a callback which is called when process has been completed
	 * @param onProgress a callback for handle progress event and cancelation.
	 * @param onError a callback which is called when an error has occured.
	 *
	 */

	public final function call(
		method		: String,
		args		: Array 	= null,
		onComplete	: Function 	= null,
		onProgress	: Function 	= null,
		onError		: Function 	= null
	) : Boolean {
		if (__isPrimordial && !__isReady) {
			error("worker is not ready");
			return false;
		}

		// sanitize the arguments
		if (args == null) args = [];
		if (onError != null && args.indexOf(onError) != -1) args.pop();
		if (onProgress != null && args.indexOf(onProgress) != -1) args.pop();
		if (onComplete != null && args.indexOf(onComplete) != -1) args.pop();

		const isOnCompletePossible:Boolean = onComplete != null;

		var workerHandlerID:uint = 0;
		if(isOnCompletePossible) {
			workerHandlerID = ++__workerHandlerID;
			__workerHandler[workerHandlerID] = new WorkerHandler(workerHandlerID, onComplete, onProgress, onError);
		}

		try {
//				send(new WorkerTask(
//					WorkerTask.CALL, 
//					new CallWorkerMessage(
//						workerHandlerID, method, args, 
//						!(onComplete == null), 
//						!(onProgress == null),
//						!(onError == null)
//					)));		
		} catch (e:*) {
			error(e);
			if(isOnCompletePossible) delete __workerHandler[__workerHandlerID];
			return false;
		}
		return true;
	}

	/**
	 * Calling a function on worker side, this function is only can be called from main and when not in single thread mode
	 *
	 * @param method The function name to be called.
	 * @param args The function parameters to be passed.
	 * @param onComplete a callback which is called when process has been completed
	 * @param onProgress a callback for handle progress event and cancelation.
	 * @param onError a callback which is called when an error has occured.
	 *
	 */

	public final function callWorker(
		method		: String,
		args		: Array = null,
		onComplete	: Function = null,
		onProgress	: Function = null,
		onError		: Function = null
	) : Boolean {
		if (!__singleThreadMode && __isPrimordial) {
			return call(method, args, onComplete, onProgress, onError);
		}
		return false;
	}



	/**
	 * Set the value of data on both side, so that data on both sides had the same value
	 *
	 * @param varname Property name.
	 * @param value The value to be set.
	 *
	 */

	public final function dataSet(name:String, value:*) : void {
		__DATA[name] = value;
		if(!__singleThreadMode) {
//				send(new WorkerTask(WorkerTask.DATA_SET, new DataWorkerMessage(name, value)));
		}
	}

	/**
	 * Delete the value of data on both side
	 *
	 * @param varname Property name.
	 * @param value The value to be set.
	 *
	 */

	public final function dataDelete(name:String) : void {
		delete __DATA[name];
//			if(!__singleThreadMode) send(new WorkerTask(WorkerTask.DATA_DELETE, name));
	}

	/**
	 * Returns the value of data on current side
	 *
	 * @param name Property name.
	 *
	 */

	public final function dataGet(name:String) : * {
		return __DATA[name];
	}

	/**
	 * Syncronize the data value on both side
	 *
	 * @param name Property name.
	 *
	 */

	public final function dataSync(name:String) : void {
//			if(!__singleThreadMode) send(new WorkerTask(WorkerTask.DATA_SYNC, name));
	}

	/**
	 * Destroy the worker
	 *
	 * @param callback a callback to return success or fail state
	 *
	 */

	public function destroy(callback:Function = null) : void {
		if (__isPrimordial) {
			this.call("destroy", [], function(success:Boolean):void {
				if (success) {
					__isReady = false;
					success = __worker.terminate();
					if (callback != null) callback(success);
				}
			})
		}
		else {
			if(callback!=null) callback(true);
			Reset();
		}
	}

	//[PRIVATE]//////////////////////////////////////////////////////////////////////////////

	private final function OnWorkerStateHandler(e:Event):void  {
		debug("worker state:",e.currentTarget.state, __isReady, hasEventListener(WorkerEvent.RUNNING));
		switch(e.currentTarget.state) {
			case WorkerState.RUNNING:
				__isReady = true;
				if (hasEventListener(WorkerEvent.RUNNING))
					dispatchEvent(new Event(WorkerEvent.RUNNING));
				break;
			case WorkerState.NEW:
				if (hasEventListener(WorkerEvent.NEW))
					dispatchEvent(new Event(WorkerEvent.NEW));
				break;
			case WorkerState.TERMINATED:
				Reset();
				if (hasEventListener(WorkerEvent.TERMINATED))
					dispatchEvent(new Event(WorkerEvent.TERMINATED));
				break;
		}
		if (hasEventListener(Event.WORKER_STATE))
			dispatchEvent(e);
	}

	private final function OnMessageReceived(event:Event):void {
		const msg : * = (event.currentTarget as MessageChannel).receive(true);
		trace("> onMessageReceived:", __isPrimordial, msg);
		if (msg is int) {
			ProcessMessage(msg);
		} else error("invalid message");
	}

	final private function send(workerTask:WorkerTask) : void {
//			trace("> SEND MESSAGE:", __isPrimordial, msgID, data);

		const 	msgID	:int 	= workerTask.id,
				data	:Object = workerTask.data;

		if (!__worker || __singleThreadMode) {
			SetSharedData(data);
			ProcessMessage(msgID);
			return;
		}

		if (__isPrimordial)
		{
			// Send To Worker
			if(__outgoingMessageChannel.messageAvailable) {
				__tasklist.push(workerTask);
			} else {
				SetSharedData(data);
				__incomingMessageChannel.send(msgID, 0);
			}
		}
		else
		{
			// Send to Main
			if(__outgoingMessageChannel.messageAvailable) {
				__tasklist.push(workerTask);
			} else {
				SetSharedData(data);
				__outgoingMessageChannel.send(msgID, 0);
			}

		}
	}

	private function SetSharedData(data:*):void
	{
		__sharable.position = 0;
		if(data) {
			__sharable.writeObject(data);
		}
	}

	private function GetSharedData():*
	{
		__sharable.position = 0;
		if(__sharable.bytesAvailable) {
			return __sharable.readObject();
		}
		return null;
	}

	private final function ProcessMessage(messageID:int) : void {

		var data:Object = GetSharedData();

//			trace("__processMessage", __isPrimordial, messageID, JSON.stringify(data));

		if(!data) return;

		switch(messageID) {
//				case WorkerTask.READY : __isReady = true; if (hasEventListener(WorkerEvent.READY)) { dispatchEvent(new Event(WorkerEvent.READY)); } break;
//				case WorkerTask.DEBUG : debug.apply(null, data); break;
//				case WorkerTask.ERROR : error.apply(null, data); break;
//				
//				case WorkerTask.CALL :
//					WorkerProcessMessage_Call(data as CallWorkerMessage);
//					break;
//
//				case WorkerTask.EVENT_COMPLETE:
//					ProcessMessageFromWorker_Event_Complete(data as EventWorkerMessage);
//					break;
//
//				case WorkerTask.EVENT_PROGRESS :
//					ProcessMessageFromWorker_Event_Progress(data as EventWorkerMessage);
//					break;
//				
//				case WorkerTask.EVENT_ERROR :
//					ProcessWorkerMessage_Event_Error(data as EventWorkerMessage);
//					break;			
//				
//				case WorkerTask.DATA_SET :
//					ProcessWorkerMessage_Data_Set(data as DataWorkerMessage);
//					break;
//				
//				case WorkerTask.DATA_DELETE :
//					ProcessWorkerMessage_Data_Delete(data as DataWorkerMessage);
//					break;
//				
//				case WorkerTask.DATA_SYNC :
//					ProcessWorkerMessage_Data_Sync(data as DataWorkerMessage);
//					break;
//					
//				default : 
//					error("invalid name:", messageID);
		}
	}

	private final function ProcessWorkerMessage_Data_Sync(value:DataWorkerMessage):void
	{
		const name:String = value.name;
		const data:* = __DATA[name];
		if(data) {
//				send(new WorkerTask(WorkerTask.DATA_SET, new DataWorkerMessage(name, data)));
		}
	}

	private final function ProcessWorkerMessage_Data_Delete(value:DataWorkerMessage):void
	{
		delete __DATA[value.name];
	}

	private final function ProcessWorkerMessage_Data_Set(value:DataWorkerMessage):void
	{
		if(value) __DATA[value.name] = value.data;
		else error("data value is required for property :", value.name);
	}

	private final function ProcessWorkerMessage_Event_Error(value:EventWorkerMessage):void {
		const id	: int = value.id;
		const hdlr	: WorkerHandler = __workerHandler[id] as WorkerHandler;
		const on	: Function = hdlr ? hdlr.onError : null;
		delete __workerHandler[id];
		if(on) on.apply(null, value.data);
	}

	private final function ProcessMessageFromWorker_Event_Progress(value:EventWorkerMessage):void {
		const id	: int = value.id;
		const hdlr	: WorkerHandler = __workerHandler[id] as WorkerHandler;
		const on	: Function = hdlr ? hdlr.onProgress : null;
		if (on && on.apply(null, value.data)) {
			dataSet("jobcanceled#" + id.toString(), true);
		}
	}

	private function ProcessMessageFromWorker_Event_Complete(value:EventWorkerMessage):void {
		const id	: int = value.id;
		const hdlr	: WorkerHandler = __workerHandler[id] as WorkerHandler;
		const on	: Function = hdlr ? hdlr.onComplete : null;
		delete __workerHandler[id];
		if(on) on.apply(null, value.data);
		RunNextTaskIfAvailable();
	}

	final private function WorkerProcessMessage_Call(value:CallWorkerMessage):void {
		const id		: int 		= value.id;
		const args		: Array 	= value.args;
		const method	: String 	= value.method;

		__process[id] = value;

		if (value.onComplete) {
			// inject new complete event
			args.push(
				function(...result):void {
					if(__process[id]) {
						delete __process[id];
						RunNextTaskIfAvailable();
					}
				}
			);
		}
		if (value.onProgress) {
			// inject new progress event
			args.push(function(...progress):Boolean {
				if (dataGet("jobcanceled#" + id.toString())) {
					delete __DATA["jobcanceled#" + id.toString()];
					return true;
				}
				return false;
			});
		}

		try { this[method].apply(null, args); }
		catch (e:*) {
			e["method"] = method;
			error(e);
			if (value.onError) {
				if(__process[id]) {
					delete __process[id];
				}
			}
		}
	}

	private final function RunNextTaskIfAvailable():void
	{
//			trace("__tasklist", __tasklist.length)
		if(__tasklist.length) {
			const listCopy:Vector.<WorkerTask> = __tasklist.splice(0, __tasklist.length);
			while(listCopy.length) {
				send(listCopy.shift());
			}
		}
	}

	/**
	 * Tracing a message.
	 */

	protected function debug(...args) : void {
		if (!Capabilities.isDebugger) return;
		if (__isPrimordial)
			trace.apply(null, ["Debug:"].concat(args));
//			else send(new WorkerTask(WorkerTask.DEBUG, ["[WORKER]"].concat(args))); 
	}

	/**
	 * Displaying detailed error message.
	 */

	protected function error(...args) : void {
		if (!Capabilities.isDebugger) return;
		if (__isPrimordial) {
			var error:String = args[0]+"\n";
			var leng:uint = args.length;
			while(leng--) {
				if ((args[leng] != null) && (args[leng] != undefined)) {
					var message :* = args[leng];
					var err : String = "";
					if (message is String) {
						err = message;
					} else {
						err = 	("errorID" in message?"ID: " + message.errorID + "\n":"") +
							("name" in message?"\tName: " + message.name + "\n":"") +
							("exceptionValue" in message?"\tException: " + message.exceptionValue+ "\n":"") +
							("message" in message?"\tMessage: " + message.message+ "\n":"") +
							("text" in message?"\tText: " + message.text + "\n":"");
						if ("stacktrace" in message) {
							err += "\nStack trace:";
							for (var e:int = 0; e < message.stacktrace.length; e++) {
								var stack : * = message.stacktrace[e];
								err += "\n\t"+e.toString()+" ";
								err += ("functionName" in stack?"function: " + stack.functionName + " ":"");
								err += ("sourceURL" in stack?"file: " + stack.sourceURL + " (" + ("line" in stack?stack.line.toString() + ")":"") + " ":"");
							}
						}
					}
				}
				error += err;
			}
			trace("Error:",error);
		}
//		else send(new WorkerTask(WorkerTask.ERROR, ["[WORKER]"].concat(args)));
	}
}
}
