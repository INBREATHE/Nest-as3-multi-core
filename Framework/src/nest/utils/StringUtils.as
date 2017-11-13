/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.utils
{
public final class StringUtils
{
	public static function setCharAt(str:String, char:String, index:int):String {
		return str.substr(0,index) + char + str.substr(index + 1);
	}

	public static  function replaceBackslashes($string:String, simbol:String="'"):String {
		return $string.replace(/\\/g, simbol);
	}

	public static  function replaceSymbolsWith($string:String, simbol:String, replacer:String):String {
		return $string.replace(new RegExp('/' + simbol + '/g'), simbol);
	}

	public static function getStringFromEmptyCharactersInArray(arr:Array, replacer:String = "-"):String {
		const res:Array = []; 
		arr.forEach(function(item:String, index:uint, arr:Array):void {
			if( item == null || (item && (item.length == 0 || item.charCodeAt() == 0)) ){
				res.push(replacer);
			}
		});
//		trace("> StringUtils -> getStringFromEmptyCharactersInArray: res =", res.length, res);
		return res.join("");
	}
}
}