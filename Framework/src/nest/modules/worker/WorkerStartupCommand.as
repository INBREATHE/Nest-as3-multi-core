/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker 
{
import nest.interfaces.ICommand;
import nest.patterns.command.SimpleCommand;

public class WorkerStartupCommand extends SimpleCommand implements ICommand
{
	protected var isMaster:Boolean;
	protected var isSupported:Boolean;

	public function setup( input:Object ):WorkerJunction {
		const module:WorkerModule = input as WorkerModule;
		if(module) {
			isMaster = module.isMaster;
			isSupported = module.isSupported;
			return new WorkerJunction(module);
		} else return null;
	}
}
}