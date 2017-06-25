/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker
{
import flash.data.SQLConnection;
import flash.events.Event;
import flash.events.SQLUpdateEvent;
import flash.net.registerClassAlias;
import flash.system.MessageChannel;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import nest.modules.pipes.interfaces.IPipeFitting;
import nest.modules.pipes.interfaces.IPipeMessage;
import nest.modules.pipes.plumbing.Filter;
import nest.modules.pipes.plumbing.Junction;
import nest.modules.pipes.plumbing.PipeListener;
import nest.modules.pipes.plumbing.TeeMerge;
import nest.modules.pipes.plumbing.TeeSplit;
import nest.modules.worker.messages.WorkerDBSyncMessage;
import nest.modules.worker.messages.WorkerRequestMessage;
import nest.modules.worker.messages.WorkerResponceMessage;
import nest.services.database.DatabaseService;
import nest.services.worker.process.WorkerTask;

public final class WorkerJunction extends Junction
{
	static public const FILTER_FOR_DISCONNECT_MODULE	: String = "pipeFilterDiconnectMessage";
	static public const FILTER_FOR_STORE_RESPONCE		: String = "pipeFilterInputMessage";
	static public const FILTER_FOR_APPLY_RESPONCE		: String = "pipeFilterOutputMessage";

	public var isSupported:Boolean = false;

	private const _dbService:DatabaseService = DatabaseService.getInstance();

	private const _responces:Dictionary = new Dictionary(true);

	{
		registerClassAlias(getQualifiedClassName(WorkerRequestMessage), 		WorkerRequestMessage );
		registerClassAlias(getQualifiedClassName(WorkerResponceMessage), 		WorkerResponceMessage );
		registerClassAlias(getQualifiedClassName(WorkerDBSyncMessage), 			WorkerDBSyncMessage );
	}

	public function WorkerJunction(workerModule:WorkerModule)
	{
		isSupported = workerModule.isSupported && workerModule.isInited;
		if (isSupported)
		{
			if (workerModule.isMaster) // The WRKIN pipe to the worker from all modules
			{
				const teeMerge:TeeMerge = new TeeMerge();
				const requestFilter:Filter = new Filter(
					FILTER_FOR_STORE_RESPONCE, new PipeListener(
						workerModule, function ( message:IPipeMessage ):void {
							trace("> Nest -> ", "> WorkerJunction : PipeMessage_MasterToWorker: \n\t\t : isBusy = " + this.isBusy + "\n", JSON.stringify(message) + "\n");
							this.send( new WorkerTask( WorkerTask.MESSAGE, message ));
						}
					),
					filterKeepMessageResponce as Function
				);
				teeMerge.connect(requestFilter);
				this.registerPipe( WorkerModule.WRK_IN, Junction.INPUT, teeMerge );
				trace("> Nest -> ", "> WorkerJunction : MASTER - READY!");
			}
			else // The WRKOUT pipe from the worker to all modules or main
			{
				const teeSplit:TeeSplit = new TeeSplit();
				this.registerPipe( WorkerModule.WRK_OUT, Junction.OUTPUT, teeSplit );
				this.addPipeListener( WorkerModule.WRK_OUT, workerModule, function( message:IPipeMessage ):void
				{
					trace("> Nest -> ", "> WorkerJunction : PipeMessage_WorkerToMaster: \n\t\t : isBusy = " + this.isBusy + "\n", (typeof message) + "\n");
					var taskType:int = WorkerTask.MESSAGE;
					this.send( new WorkerTask(taskType, message) );
				});

				trace("> Nest -> ", "> WorkerJunction : SLAVE - READY!");
				workerModule.send( new WorkerTask(WorkerTask.READY) );
			}

			workerModule.inputChannel.addEventListener(Event.CHANNEL_MESSAGE,
				function(junction:Junction):Function {
				const __isMaster	: Boolean 	= workerModule.isMaster;
				const __getData		: Function 	= workerModule.getSharedData;
				const __ready		: Function 	= workerModule.ready;
				const __complete	: Function 	= workerModule.completeTask;
				const __send		: Function 	= workerModule.send;
				const __terminate	: Function 	= workerModule.terminate;
				const __channel		: String 	= __isMaster ? WorkerModule.WRK_OUT : WorkerModule.WRK_IN;
				const __getPipe		: Function 	= junction.retrievePipe;

				const completeTask:Function = function():void { __send(new WorkerTask(WorkerTask.COMPLETE)); };

				const __dbConnect	: SQLConnection = _dbService.sqlConnection;
				const syncDB:Function = function(message:WorkerDBSyncMessage):void {
					__dbConnect.dispatchEvent( new SQLUpdateEvent(
						message.eventType, false, true, message.eventTable, message.eventRowID
					));
				};

				return function (e:Event):void {
					const taskType 	: * = (e.currentTarget as MessageChannel).receive(true);
					const message 	: IPipeMessage = __getData() as IPipeMessage;
					trace("> Nest -> ", "> WorkerJunction > CHANNEL_MESSAGE ", __isMaster ? "MASTER" : "SLAVE","taskType = " + taskType);
					if (taskType is int) {
						switch(taskType)
						{
							case WorkerTask.COMPLETE: __complete(); return;
							case WorkerTask.SYNC_DB: syncDB(WorkerDBSyncMessage(message)); completeTask(); break;
							case WorkerTask.TERMINATE: __terminate(); break;
							case WorkerTask.READY: __ready(); break;
							case WorkerTask.MESSAGE: {
								if(__isMaster && !filterApplyMessageResponce(message)) {
									break;
								}
								(__getPipe(__channel) as IPipeFitting).write(message);
							}
							break;
						}
						trace("> Nest -> ", "> WorkerJunction > COMPLETE TASK:", __isMaster ? "MASTER" : "SLAVE", taskType);
						__complete();
					}
				}
			}(this));

			const RetranslateDatabaseEvent:Function = function():Function
			{
				const __send		: Function 	= workerModule.send;
				const __isMaster	: Boolean 	= workerModule.isMaster;

				return function (event:SQLUpdateEvent):void
				{
					trace("> Nest -> ", "===============> RetranslateDatabaseEvent");
					workerModule.send( new WorkerTask( WorkerTask.SYNC_DB,
						new WorkerDBSyncMessage(event.type, event.table, event.rowID
					)));
				}
			}();

			_dbService.listen(SQLUpdateEvent.INSERT, null, null, RetranslateDatabaseEvent, true);
			_dbService.listen(SQLUpdateEvent.DELETE, null, null, RetranslateDatabaseEvent, true);
			_dbService.listen(SQLUpdateEvent.UPDATE, null, null, RetranslateDatabaseEvent, true);
		}
	}

	public function filterDisconnectModule(message:WorkerRequestMessage, params:Object = null):IPipeMessage
	{
		const request:String = message.getRequest();
		var disconnected:IPipeFitting;
		trace("\n> filter_DisconnectModule", request);
		switch(request)
		{
			case WorkerModule.DICONNECT_INPUT_PIPE:
			{
				trace("> Nest -> ", "> filterDisconnectOutput, DISCONNECT_INPUT_PIPE");
				disconnected = message.getBody() as IPipeFitting;
				trace("\t\t: pipeName:", disconnected.pipeName);
				trace("\t\t: channedID:", disconnected.channelID);
				if(disconnected) disconnected.disconnect();
				filterApplyMessageResponce(new WorkerResponceMessage(message.getResponce()));
				return null;
			}
			case WorkerModule.DICONNECT_OUTPUT_PIPE:
			{
				trace("> Nest -> ", "> filterDisconnectOutput, DISCONNECT_OUTPUT_PIPE");
				const teeSplit:TeeSplit = this.retrievePipe(WorkerModule.WRK_OUT) as TeeSplit;
				if(teeSplit) {
					disconnected = message.getBody() as IPipeFitting;
					if(disconnected) disconnected.disconnect();
					disconnected = teeSplit.disconnectFitting(disconnected);
					if(disconnected) disconnected.disconnect();
					filterApplyMessageResponce(new WorkerResponceMessage(message.getResponce()));
				}
				return null;
			}
		}
		return message;
	}

	public function filterApplyMessageResponce(message:IPipeMessage, params:Object = null):IPipeMessage {
		trace("> Nest -> ", "> filter_ApplyMessageResponce", (typeof message));
		const responceMessageID:String = message.getHeader() as String;
		const msgResponce:WorkerMessageResponce = _responces[responceMessageID];

		if(msgResponce) {
			const responce:* = msgResponce.getResponce();
			trace("\t\t : taskResponce =", responce);

			if(responce is Function)
			{
				responce(message);
				message = null;
			}
			else if(responce is String)
			{
				message.setHeader(String(responce));
			}
			delete _responces[responceMessageID];
		}

		return message;
	}

	public function filterKeepMessageResponce(message:WorkerRequestMessage, params:Object = null):IPipeMessage {
		trace("> Nest -> ", "> filter_KeepMessageResponce", message);
		const responcePipeID:uint = message.getPipeID();
		const responceMessageID:String = message.getMessageID();
		const responce:* = message.getResponce();

		_responces[responceMessageID] = new WorkerMessageResponce(responce, responcePipeID);
		message.setResponce(responceMessageID);

		return message;
	}
}
}