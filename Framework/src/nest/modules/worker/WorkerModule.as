/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker
{
import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.filesystem.File;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.system.WorkerState;
import flash.utils.ByteArray;

import nest.interfaces.IFacade;
import nest.modules.pipes.PipeAwareModule;
import nest.services.worker.events.WorkerEvent;
import nest.services.worker.process.WorkerTask;

public class WorkerModule extends PipeAwareModule implements IWorkerModule
{
	static public const
		TO_WRK		:String 	= 'toWorkerPipe'	/** Worker output out. 	*/
	,	FROM_WRK	:String 	= 'fromWorkerPipe'	/** Worker output in. 	*/
	,	WRK_IN		:String 	= 'workerIn'		/** Worker input in. 	*/
	,	WRK_OUT		:String 	= 'workerOut' 		/** Worker output out. 	*/
	;

	static private const
		NAME						: String 	= "worker.module"
	,	INCOMING_MESSAGE_CHANNEL	: String 	= "incomingMessageChannel"
	,	OUTGOING_MESSAGE_CHANNEL	: String 	= "outgoingMessageChannel"
	,	SHARE_DATA_PIPE				: String 	= "shareDataPipe"
	;

	static public const
		CONNECT_THROGH_JUNCTION		: String 	= "connectThroughJunction"
	,	CONNECT_MODULE_TO_WORKER	: String 	= "connectModuleToWorker"
	,	DISCONNECT_OUTPUT_PIPE		: String 	= "disconnectOutputPipe"
	,	DISCONNECT_INPUT_PIPE		: String 	= "disconnectInputPipe"
	;

	public var
		isReady 		: Boolean
	,	isMaster 		: Boolean
	,	isSupported		: Boolean
	,	isInited		: Boolean
	,	isBusy			: Boolean
	;

	public var applicationStorageDirectory:String;

	public var
		incomingMessageChannel	: MessageChannel
	,	outgoingMessageChannel	: MessageChannel
	;

	private var
		_worker  	: Worker
	,	_shareable	: ByteArray
	;

	public function get worker():Worker { return _worker; }

	private const
		_tasksQueue:Vector.<WorkerTask> = new Vector.<WorkerTask>()
	;

	/**
	 * This object is the part of Master as well as the worker
	 * It's a facade holder - entry point for worker application (like Main)
	 */
	public function WorkerModule(facade:IFacade)
    {
        super(facade);
		isSupported = Worker.isSupported;
		isMaster = Worker.current.isPrimordial;
		isInited = false;
		isReady = false;
		isBusy = false;
    }

	public function initialize(bytes:ByteArray, enabled:Boolean = true):void
	{
		trace("\n> Nest -> WorkerModule START:", 
			isMaster ? "MASTER" : "SLAVE", "enabled =", 
			enabled + "; is supported =", 
			Worker.isSupported + "; facade =", facade.key
		);

		if (isSupported && enabled)
		{
			if (isMaster)
			{
				_worker = WorkerDomain.current.createWorker(bytes, true);
				_worker.addEventListener(Event.WORKER_STATE, MasterHanlder_WorkerState, false, 0, true);

				NativeApplication.nativeApplication.addEventListener(Event.EXITING, MasterHanlder_ApplicationTerminated);

				incomingMessageChannel = Worker.current.createMessageChannel(_worker);
				outgoingMessageChannel = _worker.createMessageChannel(Worker.current);

				setSharedProperty(INCOMING_MESSAGE_CHANNEL, incomingMessageChannel);
				setSharedProperty(OUTGOING_MESSAGE_CHANNEL, outgoingMessageChannel);

				_shareable = new ByteArray();
				_shareable.shareable = true;
				setSharedProperty(SHARE_DATA_PIPE, _shareable);

				applicationStorageDirectory = File.applicationStorageDirectory.nativePath;

				_shareable.writeObject(applicationStorageDirectory);

				// Because we cant run task before worker is being ready
				// So we mark "task execution" as Busy to store all WorkerTasks in a Queue for later execution
				isBusy = true;
				isInited = true;

				trace("> Nest -> WorkerModule -> MASTER launching worker!");
				_worker.start();
			}
			else // WORKER
			{
				_worker = Worker.current;

				_worker.addEventListener(Event.WORKER_STATE, MasterHanlder_WorkerState, false, 0, true);

				outgoingMessageChannel = getSharedProperty(OUTGOING_MESSAGE_CHANNEL);
				incomingMessageChannel = getSharedProperty(INCOMING_MESSAGE_CHANNEL);

				_shareable = getSharedProperty(SHARE_DATA_PIPE);
				_shareable.shareable = true;

				applicationStorageDirectory = String(getSharedData());

				isInited = true;
				// Worker don't need to wait, it's start immediately
				
				trace("> Nest -> WorkerModule -> SLAVE starts immediately!");
				
				start();
			}
		}
        else
        {
			applicationStorageDirectory = File.applicationStorageDirectory.nativePath;
			isSupported = false;
            isInited = true;
            start();
        }
	}

	public function get outputChannel():MessageChannel { return isMaster ? incomingMessageChannel : outgoingMessageChannel; }
	public function get inputChannel():MessageChannel { return isMaster ? outgoingMessageChannel : incomingMessageChannel; }

	//==================================================================================================
	public function send(task:WorkerTask):Boolean {
	//==================================================================================================
		if(isBusy && task.id != WorkerTask.COMPLETE) {
			_tasksQueue.push(task);
		} else {
			isBusy = true;
			_shareable.clear();
			if(task.hasData()) _shareable.writeObject(task.data);
			outputChannel.send(task.id, 0);
		}
		return true;
	}

	//==================================================================================================
	public function getSharedProperty(id:String):* {
	//==================================================================================================
		return _worker.getSharedProperty(id);
	}

	//==================================================================================================
	public function terminate():void {
	//==================================================================================================
		if(!isMaster) {
			NativeApplication.nativeApplication.dispatchEvent(new Event(Event.EXITING));
		}
		_worker.terminate();
	}

	//==================================================================================================
	public function completeTask():void {
	//==================================================================================================
		isBusy = false;
		trace("> Nest -> WorkerModule", isMaster ? "MASTER" : "WORKER" ,"> completeTask => TASK QUEUE:", isMaster ? "MASTER" : "SLAVE", "length =",_tasksQueue.length);
		if(_tasksQueue.length) {
			const task:WorkerTask = _tasksQueue.shift();
			trace("\t : SEND NEXT TASK:", task.id);
			this.send(task);
		}
	}

	//==================================================================================================
	public function setSharedProperty(id:String, obj:*):void {
	//==================================================================================================
		_worker.setSharedProperty(id, obj);
	}

	//==================================================================================================
	public function setSharedData(data:*):void {
	//==================================================================================================
		
	}

	//==================================================================================================
	public function getSharedData():* {
	//==================================================================================================
		_shareable.position = 0;
		if(_shareable.bytesAvailable) {
			const obj:* = _shareable.readObject();
			trace("> Nest -> WorkerModule", isMaster ? "MASTER" : "SLAVE","getSharedData:", JSON.stringify(obj));
			return obj;
		}
		return null;
	}

	//==================================================================================================
	public function ready():void {
	//==================================================================================================
		isReady = true;
		this.dispatchEvent( new WorkerEvent( WorkerEvent.READY ));
	}

	//==================================================================================================
	public function start():void {
	//==================================================================================================
		trace("> Nest -> WorkerModule -> Starting: M =", isMaster);
		throw new Error("Method start in class that extend WorkerModule must be overwritten");
	}

	//==================================================================================================
	private function MasterHanlder_WorkerState(e:Event):void {
	//==================================================================================================
		trace("> Nest -> WorkerModule -> MasterHanlder_WorkerState:", e.currentTarget.state, isReady);
		switch(e.currentTarget.state) {
			case WorkerState.RUNNING: start(); break;
			case WorkerState.NEW: break;
			case WorkerState.TERMINATED: break;
		}
	}

	//==================================================================================================
	private function MasterHanlder_ApplicationTerminated(e:Event):void {
	//==================================================================================================
		trace("> Nest -> WorkerModule -> MasterHanlder_ApplicationTerminated:", e);
		send( new WorkerTask(WorkerTask.TERMINATE) );
	}

	public function getID():String { return moduleID; }
	public static function getNextID():String { return NAME + "." + serial++; }

	private static var serial:Number = 0;
	protected const moduleID:String = WorkerModule.getNextID();
}
}