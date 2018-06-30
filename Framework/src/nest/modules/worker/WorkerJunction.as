/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker
{
import flash.events.Event;
import flash.net.registerClassAlias;
import flash.system.MessageChannel;
import flash.utils.getQualifiedClassName;

import nest.modules.pipes.interfaces.IPipeFitting;
import nest.modules.pipes.interfaces.IPipeMessage;
import nest.modules.pipes.plumbing.Junction;
import nest.modules.pipes.plumbing.MergePipe;
import nest.modules.pipes.plumbing.PipeListener;
import nest.modules.pipes.plumbing.SplitPipe;
import nest.modules.worker.messages.WorkerDBSyncMessage;
import nest.modules.worker.messages.WorkerRequestMessage;
import nest.modules.worker.messages.WorkerResponseMessage;
import nest.services.worker.process.WorkerTask;

public final class WorkerJunction extends Junction
{
	static public const FILTER_FOR_DISCONNECT_MODULE	: String = "pipeFilterDisconnectMessage";
	static public const FILTER_FOR_KEEP_PIPE_ID			: String = "pipeFilterKeepPipeID";
	static public const FILTER_FOR_RESTORE_PIPE_ID		: String = "pipeFilterRestorePipeID";

	public var isSupported:Boolean = false;
	public var isMaster:Boolean = false;

//	private const _dbService:DatabaseService = DatabaseService.getInstance();

	{
		registerClassAlias(getQualifiedClassName(WorkerRequestMessage), 		WorkerRequestMessage );
		registerClassAlias(getQualifiedClassName(WorkerResponseMessage), 		WorkerResponseMessage );
		registerClassAlias(getQualifiedClassName(WorkerDBSyncMessage), 			WorkerDBSyncMessage );
	}

	/**
	 * This class also crated from both sides
	 * It's next level\layer of abstraction
	 * From this object pipes messages sends
	 * - WorkerModule.WRK_IN : 
	 * 		1) from application trasfered to worker through WorkerModule.send (outputChannel.send(task.id, 0))
	 * 		2) catched by worker and trasfered to junction mediators (DataProcessorJunctionMediator)
	 * - WorkerModule.WRK_OUT : 
	 * 		1) from worker transfered to application through WorkerModule.send (outputChannel.send(task.id, 0))
	 * 		2) catched from other side by this junction and sent to pipe specified in WorkerRequestMessage.responsePipeID
	 */
	public function WorkerJunction(workerModule:WorkerModule)
	{
		isSupported = workerModule.isSupported && workerModule.isInited;
		isMaster = workerModule.isMaster;

		var inputPipe:IPipeFitting = new MergePipe();
		var outputPipe:IPipeFitting = new SplitPipe();

		if (isSupported)
		{
			if (isMaster)
			{
				const toWorkerPipeListener:PipeListener = new PipeListener(workerModule, function ( message:IPipeMessage ):void {
					trace("\n> Nest -> WorkerJunction : MASTER > Output PipeListener"); 
					trace("\t : isBusy = " + this.isBusy);
					trace("\t : Send message =", message);
					trace("\t : Send message header =", message.getHeader());
					trace("\t : Send message body =", message.getBody());
					this.send( new WorkerTask( WorkerTask.MESSAGE, message ));
				});
				inputPipe.connect(toWorkerPipeListener);
				trace("> Nest -> WorkerJunction : MASTER - READY!"); 
			}
			else // WORKER
			{
				outputPipe = new PipeListener(workerModule, function ( message:IPipeMessage ):void {
					const isWorkerRequestMessage:Boolean = message is WorkerRequestMessage;
					trace("\n> Nest -> WorkerJunction : WORKER > Output PipeListener"); 
					trace("\t : isWorkerRequestMessage =", isWorkerRequestMessage);
					trace("\t : isBusy = " + this.isBusy);
					trace("\t : Send message header =", message.getHeader());
					trace("\t : Send message body =", message.getBody());
					this.send( new WorkerTask(WorkerTask.MESSAGE, message) );
				});
				trace("> Nest -> WorkerJunction : SLAVE - READY!");
			}

			workerModule.inputChannel.addEventListener(Event.CHANNEL_MESSAGE, function(junction:Junction):Function
			{
				const __isMaster	: Boolean 	= workerModule.isMaster;
				const __getData		: Function 	= workerModule.getSharedData;
				const __ready		  : Function 	= workerModule.ready;

				const __unBusyAndSendNextTask	          : Function 	= workerModule.completeTask;
				const __isTasksQueueEmpty	              : Function 	= workerModule.isTasksQueueEmpty;
				const __sendToWorkerTaskComplete	      : Function 	= workerModule.sendComplete;
				const __sendToMasterTaskCompleteConfirm	: Function 	= workerModule.sendConfirm;

				const __isBusy		: Function 	= workerModule.checkIsBusy;
				const __terminate	: Function 	= workerModule.terminate;
				const __channel		: String 	  = __isMaster ? WorkerModule.WRK_OUT : WorkerModule.WRK_IN;
				const __getPipe		: Function 	= junction.retrievePipe;
				const __transfer	: Function 	= __isMaster ? junction.sendMessage : junction.acceptMessage;

//				const __dbConnect	: SQLConnection = _dbService.sqlConnection;
//				const syncDB:Function = function(message:WorkerDBSyncMessage):void {
//					__dbConnect.dispatchEvent( new SQLUpdateEvent(
//						message.eventType, false, true, message.eventTable, message.eventRowID
//					));
//				};

				return function (e:Event):void
				{
					const taskType 	: * = (e.currentTarget as MessageChannel).receive(true);
					const message 	: IPipeMessage = __getData() as IPipeMessage;
					const pipe		  : IPipeFitting = __getPipe(__channel);
					trace("> Nest -> WorkerJunction > ", __isMaster ? "MASTER" : "WORKER", "Event.CHANNEL_MESSAGE >>>> message =", message);
					trace("> Nest -> WorkerJunction > ", __isMaster ? "MASTER" : "WORKER", "channel = " + __channel, "| pipeID = " + pipe.channelID, "| taskType = " + taskType);
					trace("> Nest -> WorkerJunction > ", __isMaster ? "MASTER" : "WORKER", "isBusy = " + __isBusy());
					if(message)
					{
						trace("> Nest -> WorkerJunction > message : pipeID = " + message.getPipeID());
						trace("> Nest -> WorkerJunction > message : messageID = " + message.getMessageID());
					}
					if (taskType is int) {
						switch(taskType)
						{
							// Only WORKER can receive this message
							case /* 15 */ WorkerTask.COMPLETE:
								__unBusyAndSendNextTask();
								__isTasksQueueEmpty() && __sendToMasterTaskCompleteConfirm();
							break;
							case /* 16 */ WorkerTask.TERMINATE: __terminate(); break;
							case /* 17 */ WorkerTask.CONFIRM: __unBusyAndSendNextTask(); break; // Only on Master when worker has no tasks
							case /*  0 */ WorkerTask.READY: __sendToWorkerTaskComplete(); __ready(); break; // Only on Master after worker initialized
							case /* 12 */ WorkerTask.MESSAGE: {
								// Because pipe.write(...) has check for channel
								__isMaster && message.setPipeID( message.getResponsePipeID() );

								__transfer( __channel, message ); // __transfer = __isMaster ? junction.sendMessage : junction.acceptMessage

								// Every worker task must be completed to be able for worker to send next task
								// It means that Master ready to accept next message from worker
								__isMaster && __sendToWorkerTaskComplete();
							}
							break;
						}
						trace("> Nest -> WorkerJunction >", __isMaster ? "MASTER" : "WORKER", "COMPLETE TASK:", taskType);
					}
				}
			}(this));

//			const RetranslateDatabaseEvent:Function = function():Function
//			{
//				const __send		: Function 	= workerModule.send;
//				const __isMaster	: Boolean 	= workerModule.isMaster;
//
//				return function (event:SQLUpdateEvent):void
//				{
//					trace("> Nest -> ", "===============> RetranslateDatabaseEvent");
//					workerModule.send( new WorkerTask( WorkerTask.SYNC_DB,
//						new WorkerDBSyncMessage(event.type, event.table, event.rowID
//					)));
//				}
//			}();

//			_dbService.listen(SQLUpdateEvent.INSERT, null, null, RetranslateDatabaseEvent, true);
//			_dbService.listen(SQLUpdateEvent.DELETE, null, null, RetranslateDatabaseEvent, true);
//			_dbService.listen(SQLUpdateEvent.UPDATE, null, null, RetranslateDatabaseEvent, true);
		}

//		const keepPipeIDFilter:Filter = new Filter(FILTER_FOR_KEEP_PIPE_ID, inputPipe, filterKeepMessagePipeID);
//		const restorePipeIDFilter:Filter = new Filter(FILTER_FOR_RESTORE_PIPE_ID, outputPipe, filterRestoreMessagePipeID);

		this.registerPipe( WorkerModule.WRK_IN, Junction.INPUT, inputPipe );
		this.registerPipe( WorkerModule.WRK_OUT, Junction.OUTPUT, outputPipe );
	}

	public function filterDisconnectModule(message:WorkerRequestMessage, params:Object = null):IPipeMessage
	{
		const request:String = message.getRequest();
//		trace("\n> Nest ->  WorkerJunction > filterDisconnectModule", request);
		var disconnected:IPipeFitting;
		switch(request)
		{
			case WorkerModule.DISCONNECT_INPUT_PIPE:
			{
				trace("> Nest -> filterDisconnectOutput, DISCONNECT_INPUT_PIPE");
				disconnected = message.getBody() as IPipeFitting;
				trace("\t\t: pipeName:", disconnected.pipeName);
				trace("\t\t: channedID:", disconnected.channelID);
				if(disconnected) disconnected.disconnect();
				return null;
			}

			case WorkerModule.DISCONNECT_OUTPUT_PIPE:
			{
				trace("> Nest -> filterDisconnectOutput, DISCONNECT_OUTPUT_PIPE");
				const teeSplit:SplitPipe = this.retrievePipe(WorkerModule.WRK_OUT) as SplitPipe;
				if(teeSplit) {
					disconnected = message.getBody() as IPipeFitting;
					trace("\t\t: pipeName:", disconnected.pipeName);
					trace("\t\t: channedID:", disconnected.channelID);
					if(disconnected) disconnected.disconnect();
					disconnected = teeSplit.disconnectFitting(disconnected);
					if(disconnected) disconnected.disconnect();
				}
				return null;
			}
		}
		return message;
	}

	public function filterRestoreMessagePipeID(message:IPipeMessage, params:Object = null):IPipeMessage {
		trace("> Nest -> filterApplyMessageResponce", (typeof message));
		return message;
	}

	public function filterKeepMessagePipeID(message:WorkerRequestMessage, params:Object = null):IPipeMessage {
		trace("> Nest -> filterKeepMessageResponce", message);
		return message;
	}
}
}