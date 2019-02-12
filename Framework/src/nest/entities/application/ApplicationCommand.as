/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.application
{
public class ApplicationCommand
{
	static private const PREFIX:String = "nest_command_application_";
	static public const
		SINGLE_REPORT			: String = "report_single"

	,	SERVER_REQUEST			: String = PREFIX + "server_request"
	,	SERVER_RESPONSE			: String = PREFIX + "server_responce"
	
	,	CHANGE_LANGUAGE			: String = PREFIX + "change_language"
	,	LOCALIZE_ELEMENT		: String = PREFIX + "localize_element"

	,	CACHE_STORE_REPORT		: String = PREFIX + "cache_report"
	,	CACHE_STORE_REQUEST		: String = PREFIX + "cache_request"
	,	CACHE_CLEAR_REPORT		: String = PREFIX + "cache_clear_report"
	,	CACHE_CLEAR_REQUEST		: String = PREFIX + "cache_clear_request"
	,	CACHE_BATCH_REPORT		: String = PREFIX + "cache_batch_reports"
	,	CACHE_BATCH_REQUESTS	: String = PREFIX + "cache_batch_requests"
	;
}
}