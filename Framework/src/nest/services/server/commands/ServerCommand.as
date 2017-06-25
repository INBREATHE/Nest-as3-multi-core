/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.server.commands
{
import nest.entities.application.ApplicationCommand;
import nest.patterns.command.SimpleCommand;
import nest.services.cache.entities.CacheRequest;
import nest.services.server.consts.ServerRequestType;
import nest.services.server.consts.ServerStatus;
import nest.services.server.entities.ServerProcess;
import nest.services.server.entities.ServerResponse;

public class ServerCommand extends SimpleCommand
{
	private final function RequestMethod(type:String, path:String, data:Object, callback:Object, cache:Boolean):void {
		var method:Function = Request;
		if(cache) method = CachedRequest;
		method(type, path, data, callback);
	}

	private final function Request(serverRequestType:String, path:String, data:Object, callback:Object):void {
		const serverProcess	: ServerProcess = new ServerProcess( path, data, callback );
		this.exec( ApplicationCommand.SERVER_REQUEST, serverProcess, serverRequestType );
	}

	private final function CachedRequest(type:String, path:String, data:Object, callback:Object):void {
		const cache:CacheRequest = this.Cache(type, path, data);
		this.Request(type, path, data, function(result:Object):void {
			if(ServerStatus.ALLOW(result)) {
				ExecuteClearRequestCommandWhenServerStatusOk(result, cache);
				ExecuteServerResponceCommandWithCallback(callback, result);
			}
		})
	}

	private final function ExecuteServerResponceCommandWithCallback(callback:Object, result:Object):void {
		if(callback != null) this.exec( ApplicationCommand.SERVER_RESPONSE, new ServerResponse(callback, result) );
	}

	private final function ExecuteStoreCacheRequestCommand(value:CacheRequest):void {
		this.exec( ApplicationCommand.CACHE_STORE_REQUEST, value );
	}

	private final function ExecuteClearRequestCommandWhenServerStatusOk(serverData:Object, cacheRequest:CacheRequest):void {
		if(serverData.status == ServerStatus.OK) this.exec( ApplicationCommand.CACHE_CLEAR_REQUEST, cacheRequest );
	}

	public final function Cache(type:String, path:String, data:Object):CacheRequest {
		const result:CacheRequest = new CacheRequest(type, path, data);
		this.ExecuteStoreCacheRequestCommand(result);
		return result;
	}

	public final function Get( path:String, data:Object, callback:Object ):void {
		RequestMethod(ServerRequestType.GET, path, data, callback, false);
	}

	public final function Update(path:String, data:Object, callback:Object, cache:Boolean = false):void {
		RequestMethod(ServerRequestType.UPDATE, path, data, callback, cache);
	}

	public final function Delete(path:String, data:Object, callback:Object, cache:Boolean = false):void {
		RequestMethod(ServerRequestType.DELETE, path, data, callback, cache);
	}

	/**
	 * Этот метод отправляет GET запрос на сервер с возможностью его предварительного кэширования (на случай если пользователь закроет окно раньше чем придет ответ)
	 * В запросе, система автоматическе проверит на наличие сети (networkProxy.isNetworkAvailable). Если сеть отсутствует вернется сообщение с данными { status: ServerStatus.ERROR, message: "No network" }
	 *
	 * @param path - путь на сервере
	 * @param data - данные которые сериализуются в строку JSON.stringify(data)
	 * @param callback - это ответ внутри приложение на запрос, может быть Function, CommandName или NotificationName
	 * @param cache - метка о кэширование запроса. Кэш-запрос будет автоматически удален если ServerResponse.result.status == ServerStatus.OK
	 */
	public final function Post(path:String, data:Object, callback:Object, cache:Boolean = false):void {
		RequestMethod( ServerRequestType.POST, path, data, callback, cache );
	}
}
}