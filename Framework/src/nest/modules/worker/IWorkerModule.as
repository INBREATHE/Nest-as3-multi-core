/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.modules.worker
{
import nest.modules.pipes.interfaces.IPipeAware;

public interface IWorkerModule extends IPipeAware
{
	function start():void;
}
}