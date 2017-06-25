/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.server
{
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;

import nest.interfaces.IServiceLocale;
import nest.services.server.consts.ServerStatus;
import nest.services.server.entities.ServerRequest;
import nest.services.server.entities.ServerResponse;

public final class ServerService extends URLLoader implements IServiceLocale
{
	private static const
		REQUEST				: Array 	= ["", "", ""]
	,	TYPE_JSON			: String 	= "application/json"
	;

	private var
		_currentRequest		: ServerRequest
	,	_header				: URLRequestHeader
	,	_isloading			: Boolean = false
	,	_currentLanguage	: String
	;

	private const
		_stack				: Array = []
	;

	/**
	 * Initialize server header, store url
	 * param serverVO - ServerVO(url, head, key)
	 */
	public function init( serverVO:Object ):void {
		REQUEST[0] = serverVO.url;
		_header = new URLRequestHeader(serverVO.head, serverVO.key);
		this.dataFormat = URLLoaderDataFormat.TEXT;
		this.addEventListener(IOErrorEvent.IO_ERROR, Handle_LoadError);
		this.addEventListener(Event.COMPLETE, Handle_LoadComplete);
	}

	//==================================================================================================
	public function sendPost(path:String, data:Object, callback:Object = null):void {
	//==================================================================================================
		SendRequest(FormPostRequest(path, data), callback);
	}

	//==================================================================================================
	public function sendGet(path:String, data:Object, callback:Object = null):void {
	//==================================================================================================
		SendRequest(FormGetRequest(path, data), callback);
	}

	//==================================================================================================
	private function SendRequest(request:URLRequest, callback:Object = null):void {
	//==================================================================================================
		const rqst:ServerRequest = new ServerRequest();
		rqst.callback = callback;
		rqst.request = request;
		if(_isloading == false)
				StartRequest(rqst);
		else 	StackRequest(rqst);
	}

	//==================================================================================================
	private function StartRequest(value:ServerRequest):void {
	//==================================================================================================
		_isloading = true;
		_currentRequest = value;
		this.load(value.request);
	}

	//==================================================================================================
	private function StackRequest(value:ServerRequest):void {
	//==================================================================================================
		_stack.push(value);
	}

	//==================================================================================================
	private function FormGetRequest(name:String, param:Object = null):URLRequest {
	//==================================================================================================
		const result:URLRequest = new URLRequest();
		result.requestHeaders.push(_header);
		if(param) REQUEST[2] = param is String ? param : Utils_ObjectToGetString(param);
		REQUEST[1] = name;

		result.url = REQUEST.join("");
		trace("> Nest -> ServerService: FormGetRequest = " + REQUEST.join(""), result.data);

		REQUEST[1] = "";
		REQUEST[2] = "";
		return result;
	}

	//==================================================================================================
	private function FormPostRequest(name:String, data:Object = null):URLRequest {
	//==================================================================================================
		const result:URLRequest = new URLRequest();
		result.requestHeaders.push(_header);
		REQUEST[1] = name;

		if(!data.hasOwnProperty("lng") && _currentLanguage) data.lng = _currentLanguage;

		result.url = REQUEST.join("");
		result.data = JSON.stringify(data);
		result.method = URLRequestMethod.POST;
		result.contentType = TYPE_JSON;

		trace("> Nest -> ServerService: FormPostRequest = " + REQUEST.join(""), result.data);

		REQUEST[1] = "";
		REQUEST[2] = "";

		return result;
	}

	//==================================================================================================
	//========= HANDLER ================================================================================
	//==================================================================================================
	private function Handle_LoadError(event:IOErrorEvent):void {
		trace("> Nest -> ServerService : ERROR RESPONCE - callback type:", typeof _currentRequest.callback, this.data);
		ProcessResult({ status:ServerStatus.ERROR, message:event.text });
	}

	private function Handle_LoadComplete(event:Event):void {
		trace("> Nest -> ServerService : RESULT RESPONCE - callback type:", typeof _currentRequest.callback, this.data);
		ProcessResult( JSON.parse(this.data) );
	}

	//==================================================================================================
	//========= RESULT PROCESS ========================================================================
	//==================================================================================================
	private function ProcessResult(value:Object):void {
		if(_currentRequest.callback != null)
			this.dispatchEvent(new ServerResponse(_currentRequest.callback, value));

		this.data = null;
		_isloading = false;
		_currentRequest = null;

		if(_stack.length)
			StartRequest(_stack.shift());
	}

	//==================================================================================================
	//========= UTILS =================================================================================
	//==================================================================================================
	private function Utils_ObjectToGetString( param:Object ):String {
		const params 	: Array = [ "?lng=" + _currentLanguage ];
		const sendItem 	: Array = ["", "=", ""];
		var key:String = "";
		for(key in param) {
			sendItem[0] = key;
			sendItem[2] = String(param[key]);
			params.push(sendItem.join(""));
		}
		return params.join("&");
	}

	public function set language(value:String):void { _currentLanguage = value; }

	private static const _instance:ServerService = new ServerService();
	public function ServerService() { if(_instance != null) throw new Error("This is a singleton class, use .getInstance()"); }
	public static function getInstance():ServerService { return _instance; }
}
}