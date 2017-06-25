/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.reports.commands
{
import nest.entities.application.ApplicationCommand;
import nest.patterns.command.SimpleCommand;
import nest.services.cache.entities.CacheReport;
import nest.services.network.NetworkProxy;
import nest.services.reports.ReportProxy;

public final class SendReportCommand extends SimpleCommand
{
	[Inject] public var reportProxy 	: ReportProxy;
	[Inject] public var networkProxy 	: NetworkProxy;

	// Прежде чем отсылать "отчет" мы сохраняем его, на тот случай если отправка не получится
	// или произойдет ошибка на сервере, или пользователь закроет приложение раньше чем придет ответ
	// После того как сервер ответил на запрос положительно (OK) мы удаляем событие из кэша
	// В команде ClearReportCacheCommand

	override public function execute(params:Object, name:String):void {
		const cacheReport : CacheReport = new CacheReport(name, reportProxy.currentTime, params);
		trace("> Nest -> ReportCommand: " + name + " isNetworkAvailable =", networkProxy.isNetworkAvailable);

		this.exec( ApplicationCommand.CACHE_STORE_REPORT, cacheReport );
		if(networkProxy.isNetworkAvailable) reportProxy.report(cacheReport);
	}
}
}