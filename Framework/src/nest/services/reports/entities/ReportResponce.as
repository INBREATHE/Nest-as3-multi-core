/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.reports.entities
{
import flash.events.Event;

import nest.services.cache.entities.CacheReport;

public final class ReportResponce extends Event
{
	public static const
		COMPLETE:String = "nest_report_responce_complete"
	;

	private var _cache:CacheReport;
	public function get report():CacheReport { return _cache; }

	public function ReportResponce(cache:CacheReport)
	{
		super(COMPLETE, false, false);
		this._cache = cache;
	}
}
}