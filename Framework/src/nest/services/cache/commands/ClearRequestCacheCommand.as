/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.cache.commands
{
import nest.patterns.command.SimpleCommand;
import nest.services.cache.entities.CacheRequest;
import nest.services.cache.CacheService;

public final class ClearRequestCacheCommand extends SimpleCommand
{
	/**
	 * Эта команда вызывается для стирания запроса из кэша по его параметрам
	 * @body - это данные CacheRequest
	 */
	private const _service:CacheService = CacheService.getInstance();

	override public function execute( body:Object, type:String ) : void {
		trace("> Nest -> ClearRequestCacheCommand: " + body);
		_service.clearRequest(body as CacheRequest);
	}
}
}