/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.server
{
import nest.entities.application.ApplicationCommand;
import nest.services.localization.LanguageDependentProxy;
import nest.services.server.ServerService;
import nest.services.server.consts.ServerRequestType;
import nest.services.server.entities.IServerData;
import nest.services.server.entities.ServerProcess;
import nest.services.server.entities.ServerResponse;

public class ServerProxy extends LanguageDependentProxy
{
	public function ServerProxy() {
		super(ServerService.getInstance());
		_server.addEventListener(ServerResponse.COMPLETE, HandleServerRespond);
	}

	//==================================================================================================
	override public function onRegister():void { trace(">\t ServerProxy: Registered"); }
	//==================================================================================================

	//==================================================================================================
	public function serverProcess(type:String, process:ServerProcess):void {
	//==================================================================================================
		var method:Function;
		switch(type)
		{
			case ServerRequestType.GET: 	method = _server.sendGet; 	break;
			case ServerRequestType.POST: 	method = _server.sendPost;  break;
		}
		if (method != null) method( process.path, process.data, process.callback );
	}

	//==================================================================================================
	private function HandleServerRespond(responce:IServerData):void {
	//==================================================================================================
		this.exec( ApplicationCommand.SERVER_RESPONSE, responce );
	}

	//==================================================================================================
	override public function languageChanged():void {
	//==================================================================================================
		_server.language = this.facade.currentLanguage;
		trace(">\t ServerProxy: languageChanged");
	}

	private function get _server():ServerService { return ServerService(data); }
}
}
