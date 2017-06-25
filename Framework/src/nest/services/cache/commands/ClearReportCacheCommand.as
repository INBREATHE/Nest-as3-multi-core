/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.cache.commands
{
import nest.patterns.command.SimpleCommand;
import nest.services.cache.entities.CacheReport;
import nest.services.cache.CacheService;

public final class ClearReportCacheCommand extends SimpleCommand
{
	/**
	 * Эта команда вызывается для очистки определенного типа кэша
	 * @body - это данные CacheEvent
	 */
	private const _service:CacheService = CacheService.getInstance();

	override public function execute( body:Object, type:String ):void {
		trace("> Nest -> ClearReportCacheCommand: ", body);
		_service.clearReport(body as CacheReport);
	}
}
}
