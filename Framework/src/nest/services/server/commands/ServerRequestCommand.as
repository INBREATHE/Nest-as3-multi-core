/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.server.commands
{
import nest.entities.application.ApplicationCommand;
import nest.patterns.command.SimpleCommand;
import nest.services.network.NetworkProxy;
import nest.services.server.entities.ServerProcess;
import nest.services.server.ServerProxy;
import nest.services.server.entities.ServerResponse;

public final class ServerRequestCommand extends SimpleCommand
{
	[Inject] public var serverProxy		: ServerProxy;
	[Inject] public var networkProxy	: NetworkProxy;

	/**
	 * In compare to ProcessEventCommand this name does not save processed objects - ServerProcess
	 * you should do this manually in callback ( which might be function or name )
	 */
	//==================================================================================================
	override public function execute( body:Object, type:String ) : void {
	//==================================================================================================
		trace("> Nest -> ServerRequestCommand: type = " + type, "path = " + ServerProcess(body).path + " isNetworkAvailable = " + networkProxy.isNetworkAvailable);
		if(networkProxy.isNetworkAvailable) {
			// After response will be received
			// serverProxy will start name: ApplicationCommand.SERVER_RESPONSE
			// with callback as notification type and result as a body
			serverProxy.serverProcess(type, ServerProcess(body));
		}
		else SendNoNetworkResponce(ServerProcess(body));
	}

	private function SendNoNetworkResponce(process:ServerProcess):void {
		const callback : Object = process.callback;
		if(callback != null)
			this.exec( 	ApplicationCommand.SERVER_RESPONSE,
						ServerResponse.CREATE_NO_NETWORK_RESPONSE(callback)
			);
	}
}
}