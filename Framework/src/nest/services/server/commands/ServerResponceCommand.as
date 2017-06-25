/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.server.commands
{
import nest.interfaces.INotifier;
import nest.patterns.command.SimpleCommand;
import nest.services.server.entities.IServerData;

public final class ServerResponceCommand extends SimpleCommand
{
	//==================================================================================================
	override public function execute( body:Object, type:String ) : void {
	//==================================================================================================
		const responce	: IServerData = body as IServerData;
		const callback	: Object = responce.callback;
		const data		: Object = responce.data;
		const isFunc	:Boolean = callback is Function;
		
		trace("> Nest -> ServerResponceCommand : callback is function =", isFunc);

		if(isFunc) callback.call(this as INotifier, data);
		else {
			if(this.commandExist(String(callback)))
					this.exec(String(callback), data);
			else 	this.send(String(callback), data);
		}
	}
}
}