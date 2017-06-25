/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.cache.commands
{
import nest.services.cache.CacheService;
import nest.services.cache.entities.CacheRequest;
import nest.services.server.commands.ServerCommand;
import nest.services.server.consts.ServerRequestType;
import nest.services.server.consts.ServerStatus;

public final class BatchRequestsCacheCommand extends ServerCommand
{
	private const cacheService:CacheService = CacheService.getInstance();

	override public function execute( body:Object, type:String ) : void {
		trace("> Nest -> BatchRequestsCacheCommand");
		if(cacheService.requestsCount == 0) return;
		else CollectRequestsFromCacheAndSendIt();
	}

	private function CollectRequestsFromCacheAndSendIt():void {
		const that		: ServerCommand = this;
		const requests	: Vector.<CacheRequest> = cacheService.requests;
		var length		: uint = requests.length;
		var index		: uint = 0;

		const sendCacheRequest:Function = function(cache:CacheRequest):Function {
			trace("\t\tCacheRequest:", cache.method);

			const callback:Function = function(result:Object):void {
				if(result && ServerStatus.EXIST(result)) {
					if(result.status == ServerStatus.OK)
						cacheService.clearRequest(cache);
				}
				// Поскольку мы удаляем удачные запросы из кэша, то мы пропускаем индекс неотправленных
				// В случае удачных запросов ClearRequesтtWhenServerStatusOk удаляет текущий cache в текущем индексе
				// Поэтому мы не сдвигаем индекс а только корректируем длину массива запросов
				if(length == requests.length) index++;
				else length = requests.length;

				if(index < length) sendCacheRequest(requests[index]);
			};

			switch(cache.type)
			{
				case ServerRequestType.GET: 	that.Get(cache.method, cache.data, callback); 		break;
				case ServerRequestType.POST: 	that.Post(cache.method, cache.data, callback); 		break;
				case ServerRequestType.UPDATE: 	that.Update(cache.method, cache.data, callback); 	break;
				case ServerRequestType.DELETE: 	that.Delete(cache.method, cache.data, callback);	break;
			}
		};
		sendCacheRequest(requests[index]);
	}
}
}