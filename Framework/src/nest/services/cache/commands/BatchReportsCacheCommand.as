/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package nest.services.cache.commands
{
import nest.patterns.command.SimpleCommand;
import nest.services.cache.CacheService;
import nest.services.cache.entities.CacheReport;
import nest.services.reports.ReportService;

public final class BatchReportsCacheCommand extends SimpleCommand
{
	private const cacheService:CacheService = CacheService.getInstance();

	override public function execute( body:Object, type:String ) : void {
		trace("> Nest -> BatchReportsCacheCommand: " + cacheService.reportsCount);
		if(cacheService.reportsCount == 0) return;
		else CollectEventsFromCacheAndSendItWithBatch();
	}

	//==================================================================================================
	private function CollectEventsFromCacheAndSendItWithBatch():void {
	//==================================================================================================
		const reportService	: ReportService = ReportService.getInstance();
		const reports		: Vector.<CacheReport> = cacheService.reports;
		var cache			: CacheReport;
		var length			: uint = reports.length;
		while(length--) {
			// Do not remove report while we have not positive answer from server
			// If batch succesful then all reports in this batch removed from list.
			cache = reports[length];
			trace(" \t\t * CacheReport:", cache.name);
			// isbatch == true - collect all messages (second parameter is true),
			// and then all batch send to server from command ReportService.batch()
			reportService.report(cache, true);
		}
		reportService.batch();
	}
}
}