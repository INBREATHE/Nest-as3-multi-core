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

public final class CacheReportCommand extends SimpleCommand
{
	/**
	 * Эта команда вызывается для сохранения определенного типа кэша
	 * @body - это данные для сохранения
	 * - CacheReport
	 */
	private const service:CacheService = CacheService.getInstance();

	override public function execute( body:Object, type:String ) : void {
		trace("> Nest -> CacheReportCommand: " + CacheReport(body).name);
		service.cacheReport(body as CacheReport);
	}
}
}