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
import nest.modules.pipes.plumbing.TeeMerge;
import nest.patterns.mediator.Mediator;
import nest.patterns.observer.NFunction;

public class WorkerModuleMediator extends Mediator
{
	public static const NAME:String = 'WorkerModuleMediator';

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

		worker.acceptInputPipe( WorkerModule.WRK_IN, workerInPipe );
		module.acceptOutputPipe( WorkerModule.TO_WRK, workerInPipe );

		worker.acceptOutputPipe( WorkerModule.WRK_OUT, workerOutPipe );
		module.acceptInputPipe( WorkerModule.FROM_WRK, workerOutPipe );
	}

	private function ConnectThrowJunction( body:Object, type:String ):void
	{
		trace("> Nest -> ", "> WorkerModuleMediator : ConnectThrowJunction", body);

		const inputModuleJunction	: Junction 		= body as Junction;
		const inputModuleToWrkPipe	: IPipeFitting 	= inputModuleJunction.retrievePipe(WorkerModule.TO_WRK);
		const inputModuleInTee		: TeeMerge 		= inputModuleJunction.retrievePipe(WorkerModule.FROM_WRK) as TeeMerge;

		if(inputModuleToWrkPipe == null || inputModuleToWrkPipe == null) throw new Error("Connect through junction impossible - no pipes");

		// The junction was passed from another module
		const wrkToInputModulePipe	: Pipe = new Pipe(inputModuleToWrkPipe.channelID);

		worker.acceptInputPipe( WorkerModule.WRK_IN, 	inputModuleToWrkPipe );
		worker.acceptOutputPipe( WorkerModule.WRK_OUT, 	wrkToInputModulePipe );

		inputModuleInTee.connectInput(wrkToInputModulePipe);
	}

	/**
	 * The Worker Module.
	 */
	protected function get worker():WorkerModule
	{
		return viewComponent as WorkerModule;
	}
}
}