/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.cache
{
import flash.data.EncryptedLocalStore;
import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.system.Capabilities;
import flash.system.Worker;
import flash.utils.ByteArray;

import nest.interfaces.IServiceLocale;
import nest.services.cache.entities.CacheReport;
import nest.services.cache.entities.CacheRequest;

public final class CacheService implements IServiceLocale
{
	private static const
		REPORTS			: String = "reports"
	,	REQUESTS		: String = "requests"
	,	LANGUAGE		: String = "language"
	,	FILE_NAME		: String = "\\cache"
	;

	private const
		_reports		: Vector.<CacheReport> 		= new Vector.<CacheReport>
	,	_requests		: Vector.<CacheRequest> 	= new Vector.<CacheRequest>
	,	_isSupported	: Boolean = EncryptedLocalStore.isSupported;

	private var
		_oData 	: Object
	,	_stream	: FileStream
	;

	//==================================================================================================
	public function init( path:Object ):void {
	//==================================================================================================
		trace("> Nest -> \t> CacheService  \t-> init: _isSupported =", _isSupported, path);
		if(!_isSupported && path) {
			const filePath:String = String(path) + FILE_NAME;
			const fileCache:File = File.applicationDirectory.resolvePath(filePath); 
			trace("> Nest -> \t> CacheService  \t-> file exist:", fileCache.exists);
			_stream = new FileStream();
			_stream.open( fileCache, FileMode.UPDATE );
			const dataString:String = _stream.bytesAvailable ? _stream.readUTF() : null;
			_oData = dataString ? JSON.parse( dataString ) : {};
			trace("> Nest -> \t> CacheService  \t-> init: EncryptedLocalStore not supported, use plane json file: " + filePath);
			trace("> Nest -> \t> CacheService  \t-> init: _oData", JSON.stringify(_oData));
			_stream.close();
			_stream.open(fileCache, FileMode.WRITE);
		}

		//http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/Capabilities.html#language
		if ( this.language == null ) this.language = Capabilities.language;

		this.parse( REPORTS, function(item:Object, index:uint, arr:Array):void {
			if(item) {
//				trace("> Nest -> Cached REPORT:", item.name, item.time,  item.params);
				_reports.push( new CacheReport( item.name, item.time, item.params ));
			}
		});
		
		_reports.sort( function compare(x:CacheReport, y:CacheReport):Number {
			return x.time < y.time ? -1 : 1;
		});

		this.parse( REQUESTS, function(item:Object, index:uint, arr:Array):void {
			if(item) {
//				trace("> Nest -> Cached REQUEST:", item.type, item.method, item.data);
				_requests.push( new CacheRequest(item.type, item.method, item.data));
			}
		});

		trace("> Nest -> \t> CacheService  \t-> init: language = " +  this.language, "_reports = " + _reports.length, "_requests = " + _requests.length);

		NativeApplication.nativeApplication.addEventListener( Event.EXITING, HandleExiting );
	}

	public function set language( value:String ):void { this.store( LANGUAGE, value ); }

	public function cacheReport		(obj:CacheReport)	: void { _reports.push(obj); }
	public function cacheRequest	(obj:CacheRequest)	: void { _requests.push(obj); }
	public function clearReport		(obj:CacheReport)	: void { const clearIndex:int = _reports.indexOf(obj); if(clearIndex >= 0) _reports.removeAt(clearIndex); }
	public function clearRequest	(obj:CacheRequest)	: void { const clearIndex:int = _requests.indexOf(obj); if(clearIndex >= 0) _requests.removeAt(clearIndex); }
	public function get reports()		: Vector.<CacheReport> { return _reports; }
	public function get requests()		: Vector.<CacheRequest> { return _requests; }
	public function get language()		: String { return retrieve( LANGUAGE ); }
	public function get reportsCount()	: uint { return _reports.length; }
	public function get requestsCount()	: uint { return _requests.length; }

	//==================================================================================================
	public function store(key:String, value:Object):void {
	//==================================================================================================
		if ( _isSupported ) {
			const bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes( String( value ));
			EncryptedLocalStore.setItem( key, bytes );
		} else {
			_oData[ key ] = value;
		}
	}

	//==================================================================================================
	public function retrieve( key:String ):String {
	//==================================================================================================
		if ( _isSupported ) {
			const ba:ByteArray = EncryptedLocalStore.getItem( key );
			return ( ba && ba.bytesAvailable ) ? ba.toString() : null;
		} else {
			trace("> Nest -> CacheService > retrieve: key =", key);
			trace("> Nest -> CacheService > retrieve: value =", _oData[key]);
			return _oData[ key ];
		}
	}

	//==================================================================================================
	public function remove( key:String ):void {
	//==================================================================================================
		if ( _isSupported )
			EncryptedLocalStore.removeItem( key );
		else delete _oData[ key ];
	}

	//==================================================================================================
	public function parse( key:String, parse:Function, keyWillBeRemoved:Boolean = false ):void {
	//==================================================================================================
		const value:String = retrieve( key );
		if ( value != null ) {
			const result:Object = JSON.parse( value );
			if ( result is Array && ( result as Array ).length > 0) ( result as Array ).forEach( parse );
			else if ( result is String || !isNaN( Number( result ))) parse.call(null, result );
			if ( keyWillBeRemoved ) remove( key );
		} else {
			parse.apply(null, new Array( parse.length ));
		}
	}

	//==================================================================================================
	private function HandleExiting( event:Event ):void {
	//==================================================================================================
		trace("> Nest -> CacheService", Worker.current.isPrimordial ? "MASTER" : "SLAVE", "> HANDLE EXITING: events | request =",_reports.length, _requests.length);
		if ( _reports.length ) 	this.store( REPORTS, 	JSON.stringify(_reports));  else this.remove(REPORTS);
		if ( _requests.length ) 	this.store( REQUESTS, 	JSON.stringify(_requests)); else this.remove(REQUESTS);

		trace("> \t\t", "_oData:", JSON.stringify(_oData));
		if ( _oData )
		{
			_stream.writeUTF( JSON.stringify( _oData ));
			_stream.close();
		}
		NativeApplication.nativeApplication.removeEventListener( Event.EXITING, HandleExiting );
	}

	private static const _instance:CacheService = new CacheService();
	public function CacheService() { if ( _instance != null ) throw new Error("This is a singleton class, use .getInstance()"); }
	public static function getInstance():CacheService { return _instance; }
}
}