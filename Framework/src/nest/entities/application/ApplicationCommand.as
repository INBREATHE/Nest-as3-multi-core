/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.application
{
public class ApplicationCommand
{
	static public const
		SINGLE_REPORT			: String = "nest_command_application_report_single"

	,	SERVER_REQUEST			: String = "nest_commands_application_server_request"
	,	SERVER_RESPONSE			: String = "nest_commands_application_server_responce"
	
	,	CHANGE_LANGUAGE			: String = "nest_commands_application_change_language"

	,	CACHE_STORE_REPORT		: String = "nest_command_cache_report"
	,	CACHE_STORE_REQUEST		: String = "nest_command_cache_request"
	,	CACHE_CLEAR_REPORT		: String = "nest_command_cache_clear_report"
	,	CACHE_CLEAR_REQUEST		: String = "nest_command_cache_clear_request"
	,	CACHE_BATCH_REPORT		: String = "nest_command_cache_batch_reports"
	,	CACHE_BATCH_REQUESTS	: String = "nest_command_cache_batch_requests"
	;
}
}