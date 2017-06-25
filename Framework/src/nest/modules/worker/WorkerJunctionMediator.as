/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker
{
import nest.modules.pipes.interfaces.IPipeFitting;
import nest.modules.pipes.plumbing.Filter;
import nest.modules.pipes.plumbing.Junction;
import nest.modules.pipes.plumbing.JunctionMediator;
import nest.modules.pipes.plumbing.PipeListener;
import nest.modules.pipes.plumbing.TeeMerge;
import nest.modules.pipes.plumbing.TeeSplit;

public class WorkerJunctionMediator extends JunctionMediator
{
	public function WorkerJunctionMediator( workerJunction:WorkerJunction )
	{
		super( workerJunction || new Junction() );
	}

	public function get workerJunction():WorkerJunction
	{
		return junction as WorkerJunction;
	}

	override public function onRegister():void {
		const workerNotSupported:Boolean = workerJunction && !workerJunction.isSupported;
		// MASTER
		if (!junction.hasPipe(WorkerModule.WRK_OUT)) {
			// The WRKOUT pipe from the worker to all modules or main
			var teeOut:IPipeFitting = new TeeSplit();
			if(workerNotSupported) {
				const filter:Filter = new Filter(
					WorkerJunction.FILTER_FOR_APPLY_RESPONCE, teeOut,
					workerJunction.filterApplyMessageResponce as Function
				);
				teeOut = filter as IPipeFitting;
			}
			junction.registerPipe( WorkerModule.WRK_OUT, Junction.OUTPUT, teeOut );
		}
		// SLAVE
		if(!junction.hasPipe(WorkerModule.WRK_IN)) {
			// The WRKIN pipe to the worker from all modules
			const teeMerge		: TeeMerge = new TeeMerge();
			const pipeListener	: PipeListener = new PipeListener(this, handlePipeMessage);
			// This situation happend when no worker being accepted
			// Master already has PipeAwareModule.WRKIN it's only
			if(workerNotSupported)
			{
				const diconectFilter:Filter = new Filter(
					WorkerJunction.FILTER_FOR_DISCONNECT_MODULE, pipeListener,
					workerJunction.filterDisconnectModule
				);

				const responceFilter:Filter = new Filter(
					WorkerJunction.FILTER_FOR_STORE_RESPONCE, diconectFilter,
					workerJunction.filterKeepMessageResponce as Function
				);

				teeMerge.connect(responceFilter);
			}
			else
			{
				// This only happend on Worker because he do not need to know about filtering, this is done already in Master
				teeMerge.connect(pipeListener);
			}
			junction.registerPipe( WorkerModule.WRK_IN, Junction.INPUT, teeMerge );
		}
	}
}
}