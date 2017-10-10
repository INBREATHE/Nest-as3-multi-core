/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker
{
import nest.modules.pipes.interfaces.IPipeAware;
import nest.modules.pipes.interfaces.IPipeFitting;
import nest.modules.pipes.plumbing.Junction;
import nest.modules.pipes.plumbing.Pipe;
import nest.patterns.mediator.Mediator;
import nest.patterns.observer.NFunction;

public class WorkerModuleMediator extends Mediator
{
	public static const NAME:String = 'WorkerModuleMediator';

	/**
	 * This is intermediate object which connect other modules to worker module
	 * - with Junction
	 * - as IPipeAware
	 * 
	 * It lives in application (view) facade
	 */
	public function WorkerModuleMediator( module: WorkerModule )
	{
		super( module );
	}

	override public function listNotificationsFunctions():Vector.<NFunction> {
		return new <NFunction>[
			new NFunction(WorkerModule.CONNECT_THROGH_JUNCTION, ConnectThrowJunction)
		,	new NFunction(WorkerModule.CONNECT_MODULE_TO_WORKER, ConnectModuleToWorker)
		];
	}

	private function ConnectModuleToWorker( body:Object, type:String ):void
	{
		trace("> Nest -> ", "> WorkerModuleMediator : ConnectModuleToWorker", body);

		const module		: IPipeAware = body as IPipeAware;

		const workerOutPipe	: Pipe = new Pipe(Pipe.newChannelID());
		const workerInPipe	: Pipe = new Pipe(workerOutPipe.channelID);

		workerOutPipe.channelID = workerInPipe.channelID;

		workerModule.acceptInputPipe( WorkerModule.WRK_IN, workerInPipe );
		module.acceptOutputPipe( WorkerModule.TO_WRK, workerInPipe );

		workerModule.acceptOutputPipe( WorkerModule.WRK_OUT, workerOutPipe );
		module.acceptInputPipe( WorkerModule.FROM_WRK, workerOutPipe );
	}

	private function ConnectThrowJunction( body:Object, type:String ):void
	{
		trace("\n> Nest -> WorkerModuleMediator : ConnectThrowJunction", body);

		const junction: Junction = body as Junction;

		const toWorker		: IPipeFitting 	= junction.retrievePipe( WorkerModule.TO_WRK );
		const fromWorker	: IPipeFitting 	= junction.retrievePipe( WorkerModule.FROM_WRK );

		if(toWorker == null || toWorker == null) throw new Error("Connect through junction impossible - no pipes");

		// Use junction channelID that was passed from another module

		workerModule.acceptInputPipe( WorkerModule.WRK_IN, 	toWorker );
		/**
		 * Send notification JunctionMediator.ACCEPT_OUTPUT_PIPE to DataProcessorJunctionMediator
		 * Which is already initialized from DataProcessor initialize method
		 */
		workerModule.acceptOutputPipe( WorkerModule.WRK_OUT, 	fromWorker );
	}

	// DataProcessor
	protected function get workerModule():WorkerModule { return viewComponent as WorkerModule; }
}
}