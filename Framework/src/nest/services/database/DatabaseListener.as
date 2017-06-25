/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.database
{
public final class DatabaseListener
{
	private var _callback:Function;
	private var _table:String;
	private var _classRef:Class;

	private var _retranlator:Boolean;

	public function get callback():Function { return _callback; }
	public function get table():String { return _table; }
	public function get classRef():Class { return _classRef; }

	public function get retranslator():Boolean { return _retranlator; }

	public function DatabaseListener(table:String, classRef:Class, callback:Function, retranlator:Boolean)
	{
		_classRef = classRef;
		_table = table;
		_callback = callback;
		_retranlator = retranlator;
	}
}
}