/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.database
{
import flash.events.Event;
import flash.utils.Dictionary;

import nest.services.localization.LanguageDependentProxy;

/**
 * C:\Users\DQvsRA\AppData\Roaming\[App Identifier]\Local Store\
 * @author Vladimir Cores
 */

/*
 *
	Using encryption with SQL databases
	info: http://help.adobe.com/en_US/as3/dev/WS8AFC5E35-DC79-4082-9AD4-DE1A2B41DAAF.html
*/

public class DatabaseProxy extends LanguageDependentProxy
{
	private const _events : Dictionary = new Dictionary();

	public function DatabaseProxy() { super( DatabaseService.getInstance() ); }
	
	//==================================================================================================
	override public function onRegister():void { trace(">\t DatabaseProxy: Registered");
	//==================================================================================================
	}

	public function get dbExist():Boolean { return _dbService.dbExist; }

	//==================================================================================================
	public function create( tables:Vector.<DatabaseTable>, callback:Function ):void {
	//==================================================================================================
		const nextTable:Function = function( databaseTable:DatabaseTable ):void {
			_dbService.createTable( databaseTable.tableName, databaseTable.tableClass );
		};
		const dbListener:Function = function(e:Event):void {
//			Capabilities.isDebugger && Application.log("DatabaseService.EVENT_EXECUTE_COMPLETE");
			if ( tables.length == 0 ) {
				_dbService.removeEventListener( DatabaseService.EVENT_EXECUTE_COMPLETE, dbListener );
				callback();
			} else {
				nextTable( tables.shift() );
			}
		};
		_dbService.addEventListener( DatabaseService.EVENT_EXECUTE_COMPLETE, dbListener);
		nextTable( tables.shift() );
	}

	//==================================================================================================
	public function retrieve( query:String, classRef:Class = null, all:Boolean = false, languageDependent:Boolean = true ):Object {
	//==================================================================================================
		return _dbService.retrieve(query, classRef, all, languageDependent );
	}

	//==================================================================================================
	public function select(table:String, critiria:String, classRef:Class, all:Boolean = false, languageDependent:Boolean = true):Object {
	//==================================================================================================
		return _dbService.select(table, critiria, classRef, all, languageDependent);
	}

	//==================================================================================================
	public function count( table:String, critiria:String, languageDependent:Boolean = true ):uint {
	//==================================================================================================
		return _dbService.count( table, critiria, languageDependent );
	}

	//==================================================================================================
	public function store( table:String, data:Object, languageDependent:Boolean = true ):void {
	//==================================================================================================
		_dbService.store( table, data, languageDependent );
	}

	//==================================================================================================
	public function update( table:String, criteria:String, data:Object, languageDependent:Boolean = true ):void {
	//==================================================================================================
		_dbService.update( table, criteria, data, languageDependent );
	}

	//==================================================================================================
	public function remove( table:String, criteria:String, languageDependent:Boolean = true ):void {
	//==================================================================================================
		_dbService.remove( table, criteria, languageDependent );
	}

	//==================================================================================================
	override public function languageChanged():void {
	//==================================================================================================
		_dbService.language = this.facade.currentLanguage;
		trace(">\t DatabaseProxy: languageChanged");
	}

	//==================================================================================================
	public function listen(eventType:String, table:String, classRef:Class, callback:Function):void {
	//==================================================================================================
		_dbService.listen(eventType, table, classRef, callback);
	}

	private function get _dbService():DatabaseService { return data as DatabaseService; }
}
}
