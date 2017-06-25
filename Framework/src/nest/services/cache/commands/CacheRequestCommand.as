/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.cache.commands
{
import nest.patterns.command.SimpleCommand;
import nest.services.cache.CacheService;
import nest.services.cache.entities.CacheRequest;

public final class CacheRequestCommand extends SimpleCommand
{
	/**
	 * Эта команда вызывается для сохранения определенного типа кэша
	 * @body - это данные для сохранения
	 * - CacheRequest
	 */
	private const service:CacheService = CacheService.getInstance();

	override public function execute( request:Object, type:String ) : void {
		trace("> Nest -> CacheRequestCommand");
		service.cacheRequest(request as CacheRequest);
	}
}
}