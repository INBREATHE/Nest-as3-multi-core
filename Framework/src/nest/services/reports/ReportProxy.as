/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.reports
{
import nest.entities.application.ApplicationCommand;
import nest.services.cache.entities.CacheReport;
import nest.services.localization.LanguageDependentProxy;
import nest.services.reports.entities.ReportResponce;

public final class ReportProxy extends LanguageDependentProxy
{
	public function ReportProxy()
	{
		super(ReportService.getInstance());
		_report.addEventListener(ReportResponce.COMPLETE, HandleReportResponceComplete);
	}
	
	//==================================================================================================
	override public function onRegister():void { trace(">\t ReportProxy: Registered"); }
	//==================================================================================================

	public function get currentTime():uint { return _report.currentTime; }

	//==================================================================================================
	public function report(cache:CacheReport):void { _report.report(cache, false); }
	public function reportBatch(cache:CacheReport):void { _report.report(cache, true); }
	public function batch():void { _report.batch(); }
	//==================================================================================================

	//==================================================================================================
	private function HandleReportResponceComplete(event:ReportResponce):void {
	//==================================================================================================
		this.exec( ApplicationCommand.CACHE_CLEAR_REPORT, event.report );
	}

	//==================================================================================================
	override public function languageChanged():void {
	//==================================================================================================
		_report.language = this.facade.currentLanguage; 
		trace(">\t ReportProxy: languageChanged");
	}
	
	private function get _report():ReportService { return ReportService(data); }
}
}