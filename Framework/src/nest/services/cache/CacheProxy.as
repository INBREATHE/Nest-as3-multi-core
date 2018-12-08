/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.cache
{
import nest.services.localization.LanguageDependentProxy;

public class CacheProxy extends LanguageDependentProxy
{
	public function CacheProxy() { super(CacheService.getInstance()); }

	override public function languageChanged():void {
		_cacheService.language = this.facade.currentLanguage;
		trace(">\t CacheProxy: languageChanged");
	}

	//==================================================================================================
	override public function onRegister():void {
	//==================================================================================================
		trace(">\t CacheProxy: Registered");
	}

	public function store		(key:String, value:String):void { _cacheService.store(key, value); } 
	public function remove		(key:String):void { _cacheService.remove(key); }
	public function retrieve	(key:String):String { return _cacheService.retrieve(key); }
	public function parse		(key:String, parse:Function, keyWillBeRemoved:Boolean = false):void { return _cacheService.parse(key, parse, keyWillBeRemoved); }

	public function get language() : String { return _cacheService.language; }
	private function get _cacheService() : CacheService { return CacheService(data); }

	// " NO DATA FOR SERVICE PROXY "
	override public function getData():Object { throw new Error(); }
}
}