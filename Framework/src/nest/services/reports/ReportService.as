/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.reports
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.system.Capabilities;

import nest.interfaces.IServiceLocale;
import nest.services.cache.entities.CacheReport;
import nest.services.reports.entities.ReportResponce;
import nest.services.server.consts.ServerStatus;

public final class ReportService extends EventDispatcher implements IServiceLocale
{
	private static const
		REPORTS	: String = 'report/'
	,	BATCH	: String = REPORTS + 'batch'
	;

	private var
		_header		: URLRequestHeader
	,	_type 		: String
	,	_url 		: String
	;

	private const
		_batch		: Array 	= new Array()
	,	_date		  : Date 		= new Date()
	,	_params		: Object 	= {
			data 		: {}
		,	uuid		: ""
		,	time 		: _date.time
		,	offset 		: _date.timezoneOffset
		,	version		: Capabilities.version
		,	os			: Capabilities.version
		,	lng			: ""
	}
	;

	/**
	 * Initialize server header, store url
	 * param serverVO - ServerVO(url, head, key)
	 */
	public function init(serverVO:Object):void
	{
		_header = new URLRequestHeader(serverVO.head, serverVO.key);
		_url 	= serverVO.url;
		_type = serverVO.type;
		trace("> Nest -> \t> ReportService \t-> init: _url =", _url, "_type =", _type);
	}

	public function get currentTime():uint { return _date.time; }
	public function set uuid(value:String):void { _params.uuid = value; }
	public function set language(value:String):void { _params.lng = value; }

	/**
	 * Этот метод вызывается только из команды BatchCacheReportCommand
	 * После того как все события в из кэша перенесутся в _batch (в той же команде)
	 */
	public function batch():void {
		if(_batch.length == 0) return;
		const requests:Array = _batch.splice(0, _batch.length);
		SendAdvance(BATCH, URLRequestMethod.POST, requests,
			function(resp:Object):void {
				trace("> Nest -> ReportService - BATCH : RESULT:", JSON.stringify(resp));
				if(resp != null && resp.status == ServerStatus.OK) {
					ClearCacheReportWhenBatchOK( requests );
				}
			}
		);
	}

	//==================================================================================================
	public function report(cache:CacheReport, batch:Boolean = false):void {
	//==================================================================================================
		if(batch) _batch.push(cache);
		else SendSimple(REPORTS + cache.name, URLRequestMethod.POST, cache);
	}

	//==================================================================================================
	private function SendSimple(path:String, method:String, cache:CacheReport = null):void {
	//==================================================================================================
		var ldr:URLLoader = new URLLoader();
		const __clearLoader:Function = function ():void {
			ldr.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			ldr.removeEventListener(Event.COMPLETE, completeHandler);
			ldr.close();
			ldr = null;
		};

		const completeHandler:Function = function (resp:Event):void {
			trace("> Nest -> ReportService : completeHandler", ldr.data);
			const data:Object = ldr.data is String ? { status: ServerStatus.ERROR } : JSON.parse(ldr.data) as Object;
			if(data != null && data.status == ServerStatus.OK ) {
				ClearCacheReportWhenServerOK(cache);
				cache = null;
			}
			__clearLoader();
		};
		const errorHandler:Function = function (resp:IOErrorEvent):void {
			__clearLoader();
		};
		ldr.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		ldr.addEventListener(Event.COMPLETE, completeHandler);

		ldr.dataFormat = URLLoaderDataFormat.BINARY;
		ldr.load(FormURLRequest(path, method, cache.params));
	}

	//==================================================================================================
	private function SendAdvance(path:String, method:String, params:Object = null, successCallback:Function = null, errorCallback:Function = null):void {
	//==================================================================================================
		var ldr:URLLoader = new URLLoader();
		const __clearLoader:Function = function():void {
			if (ldr.hasEventListener(Event.COMPLETE)) ldr.removeEventListener(Event.COMPLETE, __completeHandler);
			if (ldr.hasEventListener(IOErrorEvent.IO_ERROR)) ldr.removeEventListener(IOErrorEvent.IO_ERROR, __errorHandler);
			ldr.close();
			ldr = null;
		};
		const __completeHandler:Function = function (resp:Event):void {
			trace("> Nest -> ReportService, Complete", path, successCallback);
			if (successCallback != null) successCallback(JSON.parse(ldr.data));
			__clearLoader();
		};
		const __errorHandler:Function = function (resp:IOErrorEvent):void {
			const data:* = ldr.data;
			if (errorCallback != null) errorCallback(data != null && String(data).length > 0 ? JSON.parse(data): data);
			__clearLoader();
		};

		ldr.addEventListener	( Event.COMPLETE, 			__completeHandler	);
		ldr.addEventListener	( IOErrorEvent.IO_ERROR, 	__errorHandler		);

		ldr.load(FormURLRequest(path, method, params));
	}

	//==================================================================================================
	private function FormURLRequest(path:String, method:String, params:Object):URLRequest {
	//==================================================================================================
		const req:URLRequest = new URLRequest(_url + path);
		if (params != null) {
			if (method == URLRequestMethod.GET) {
				req.data = GetVarsForParams(params);
			} else {
				_params.time = currentTime;
				_params.data = String(JSON.stringify(params));
				req.data = JSON.stringify(_params);
			}
		}

		req.contentType 	= _type;
		req.method 			= method;
		req.cacheResponse 	= false;
		req.useCache 		= false;
		req.requestHeaders.push(_header);
		trace("> Nest -> ReportService, URLRequest", req.url, JSON.stringify(params));
		return req;
	}

	//==================================================================================================
	private function ClearCacheReportWhenBatchOK(requests:Array):void {
	//==================================================================================================
		var request:CacheReport;
		while(requests.length) {
			request = requests.shift();
			ClearCacheReportWhenServerOK(request);
		}
		request = null;
	}

	//==================================================================================================
	private function ClearCacheReportWhenServerOK(cache:CacheReport):void {
	//==================================================================================================
		this.dispatchEvent(new ReportResponce(cache));
	}

	//==================================================================================================
	private function GetVarsForParams(params:Object):URLVariables {
	//==================================================================================================
		const vars:URLVariables = new URLVariables();
		var param:String;
		for (param in params) vars[param] = params[param];
		return vars;
	}

	private static const _instance:ReportService = new ReportService();
	public function ReportService() { if(_instance != null) throw new Error("This is a singleton class, use .getInstance()"); }
	public static function getInstance():ReportService { return _instance; }
}
}
