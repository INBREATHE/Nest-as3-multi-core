/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.cache
{
import nest.patterns.proxy.Proxy;

public class CacheProxy extends Proxy
{
	public function CacheProxy() { super(CacheService.getInstance()); }

	public function setupLanguage(value:String):void { _cache.language = value; }

	public function store		(key:String, value:String):void { _cache.store(key, value); }
	public function remove		(key:String):void { _cache.remove(key); }
	public function retrieve	(key:String):String { return _cache.retrieve(key); }
	public function parse		(key:String, parse:Function, willremove:Boolean = false):void { return _cache.parse(key, parse, willremove); }

	public function get language() : String { return _cache.language; }
	private function get _cache() : CacheService { return CacheService(data); }
}
}