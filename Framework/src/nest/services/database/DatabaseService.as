/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.database
{
import flash.data.SQLConnection;
import flash.data.SQLMode;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.SQLEvent;
import flash.events.SQLUpdateEvent;
import flash.filesystem.File;
import flash.system.Capabilities;
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;
import flash.utils.setTimeout;

import nest.entities.application.Application;
import nest.interfaces.IServiceLocale;

public final class DatabaseService extends EventDispatcher implements IServiceLocale
{
	private static const ERROR_NOT_INITIALIZED:String = "DatabaseService is not initialized, try to initialize it first!";

	public static const EVENT_EXECUTE_COMPLETE:String = "event_execute_complete";
	
	public static const TYPE_OBJECT:String = "object";
	public static const TYPE_STRING:String = "string";

	private const _objectPropertyNamesCache:Object = {};

	private var
		_sqlConnection	: SQLConnection
	,	_sqlStatement	  : SQLStatement
	,	_dbExist		    : Boolean = false
	,	_events			    : Dictionary = new Dictionary()
	;
	
	public function get dbExist():Boolean { return _dbExist; }

	/**
	 * Create new database file if not exist
	 * param databaseVO - DatabaseVO(name)
	 */
	//==================================================================================================
	public function init( databaseVO:Object ):void {
	//==================================================================================================
		const file:File = databaseVO.path != null ? 
				new File( databaseVO.path + "/" + databaseVO.NAME )
			: File.applicationStorageDirectory.resolvePath( databaseVO.NAME );
		
		_dbExist = file.exists;
		_sqlConnection = new SQLConnection();
		_sqlConnection.addEventListener( SQLEvent.OPEN, Handler_DatabaseOpened );
//		Capabilities.isDebugger && Application.log("> Nest -> \t> DatabaseService \t-> init: DB exist: " + _dbExist + " at path: " + file.nativePath);
		_sqlConnection.open( file, _dbExist ? SQLMode.UPDATE : SQLMode.CREATE );
	}
	
	//==================================================================================================
	private function Handler_DatabaseOpened( e:SQLEvent ):void {
	//==================================================================================================
		_sqlConnection.removeEventListener( SQLEvent.OPEN, Handler_DatabaseOpened );
		this.dispatchEvent( e );
	}

	//==================================================================================================
	public function create( tables:Dictionary, addLanguage:Boolean ):void {
	//==================================================================================================
		var dbName:String, dbClass:Class;
		for ( dbName in tables ) {
			dbClass = tables[ dbName ];
//			Capabilities.isDebugger && Application.log("> Nest -> \tDatabaseService: create db " + dbName);
			ExecuteStatement( DatabaseQuery.CreateTableFromClass( dbName, dbClass ), addLanguage );
		}
	}
	
	//==================================================================================================
	public function createTable( tableName:String, tableClass:Class ):void {
	//==================================================================================================
//		Capabilities.isDebugger && Application.log("> Nest -> \tDatabaseService: create db " + tableName, tableClass);
		ExecuteStatement( DatabaseQuery.CreateTableFromClass( tableName, tableClass ), false, null, true);
	}

	//==================================================================================================
	public function retrieve( query:String, classRef:Class = null, all:Boolean = false, languageDependent:Boolean = true):Object {
	//==================================================================================================
		ExecuteStatement( query, languageDependent, classRef );
		var result:Object = null;
		const sqlResult:SQLResult = _sqlStatement.getResult();
		if ( sqlResult ) {
			const data:Array = sqlResult.data;
//			trace("> Nest -> DatabaseService: retrieve sqlResult =", sqlResult, sqlResult.data);
			result = data ? (all ? data : data[0]) : null;
		} else {
//			trace("> Nest -> DatabaseService: ERROR retrieve:", query);
		}
		return result;
	}

	//==================================================================================================
	public function select( table:String, critiria:String, classRef:Class, all:Boolean, languageDependent:Boolean ):Object {
	//==================================================================================================
		return retrieve( DatabaseQuery.SelectFromTable( table, critiria ), classRef, all, languageDependent );
	}

	//==================================================================================================
	public function count(table:String, critiria:String, languageDependent:Boolean ):uint {
	//==================================================================================================
		const data:Array = retrieve( DatabaseQuery.CountFromTable( table, critiria ), null, true, languageDependent ) as Array;
		return data ? data[0][ DatabaseQuery.COUNT ] : 0;
	}

	//==================================================================================================
	public function store( table:String, data:Object, languageDependent:Boolean ):void {
	//==================================================================================================
		const dataType:String = typeof data;
//			trace("> Nest -> STORE:", dataType, data);
		if ( dataType == TYPE_STRING ) ExecuteStatement( DatabaseQuery.InsertDataStringToTable( String( data ), table ), languageDependent );
		else if ( dataType == TYPE_OBJECT ) ExecuteInsertStatementWithParams( data, table );
	}

	//==================================================================================================
	public function update( table:String, criteria:String, data:Object, languageDependent:Boolean ):void {
	//==================================================================================================
		if ( languageDependent ) criteria = DatabaseQuery.QueryWithLanguage( criteria );
		ExecuteUpdateStatementWithParams( data, table, criteria );
	}

	//==================================================================================================
	public function remove( table:String, criteria:String, languageDependent:Boolean ):void {
	//==================================================================================================
		ExecuteStatement( DatabaseQuery.DeleteFromTableWhere( table, criteria ), languageDependent );
	}

	//==================================================================================================
	public function listen( eventType:String, table:String, classRef:Class, callback:Function, retranslate:Boolean = false ):void {
	//==================================================================================================
		if ( _sqlConnection == null ) throw new Error( ERROR_NOT_INITIALIZED );
		if ( _sqlConnection.hasEventListener( eventType ) == false ) {
			_sqlConnection.addEventListener( eventType, HandleDatabaseEvent );
		}
		if ( _events[eventType] == null ) _events[ eventType ] = new Vector.<DatabaseListener>();
		Vector.<DatabaseListener>( _events[ eventType ]).push( new DatabaseListener( table, classRef, callback, retranslate ));
	}

	//==================================================================================================
	private function HandleDatabaseEvent( event:SQLUpdateEvent ):void {
	//==================================================================================================
//		trace("> Nest -> HandleDatabaseEvent")
		const eventType:String = event.type;
		const eventTable:String = event.table;
		const rowIDQuery:String = DatabaseQuery.RowID( event.rowID );
		const listeners:Vector.<DatabaseListener> = Vector.<DatabaseListener>(_events[eventType]);
		if ( listeners ) {
//			trace("> Nest -> UPDATED:", eventType, eventTable, event.rowID);
			const classValues:Dictionary = new Dictionary(true);
			var dbListener:DatabaseListener;
			var listenerClass:Class;
			var eventValue:Object;
			for each ( dbListener in listeners ) {
//				trace("\t> dbListener.retranslator =", dbListener.retranslator);
				if ( dbListener.retranslator && !event.cancelable ) dbListener.callback( event );
				else if ( dbListener.table == eventTable) {
					listenerClass = dbListener.classRef;
					eventValue = classValues[ listenerClass ];
					if ( eventValue == null ) {
						eventValue = this.select( eventTable, rowIDQuery, listenerClass, false, false ); // TODO: Resolve language
						classValues[ listenerClass ] = eventValue;
					}
					dbListener.callback( eventValue as listenerClass );
				}
			}
		}
	}

	//==================================================================================================
	private function ExecuteUpdateStatementWithParams(data:Object, table:String, criteria:String):void {
	//==================================================================================================
		_sqlStatement = new SQLStatement();
		_sqlStatement.sqlConnection = _sqlConnection;
		_sqlStatement.text = DatabaseQuery.UpdateTableParamsWhere(table, FillStatementParametersFromObject(_sqlStatement, data), criteria);
//		trace("> Nest -> DatabaseService Execute QUERY: " + _sqlStatement.text);
		Execute(_sqlStatement);
	}

	//==================================================================================================
	private function ExecuteInsertStatementWithParams(data:Object, table:String):void {
	//==================================================================================================
		_sqlStatement = new SQLStatement();
		_sqlStatement.sqlConnection = _sqlConnection;
		_sqlStatement.text = DatabaseQuery.InsertDataObjectToTable( FillStatementParametersFromObject( _sqlStatement, data ), table );
//		trace("> Nest -> DatabaseService Execute QUERY: " + _sqlStatement.text);
		Execute( _sqlStatement );
	}

	//==================================================================================================
	private function ExecuteStatement( query:String, addLanguage:Boolean = true, classRef:Class = null, withCallback:Boolean = false ):void {
	//==================================================================================================
		_sqlStatement = new SQLStatement();
		_sqlStatement.sqlConnection = _sqlConnection;
		if ( addLanguage ) query = DatabaseQuery.QueryWithLanguage( query );
		_sqlStatement.text = query;
		if ( classRef != null ) _sqlStatement.itemClass = classRef;
		if ( withCallback ) _sqlStatement.addEventListener( SQLEvent.RESULT, Handler_SQLStatement_Result );
		Execute(_sqlStatement);
	}

	private function Execute(stmt:SQLStatement):void {
		try {
//            trace("> Nest -> DatabaseService: Execute QUERY: " + _sqlStatement.text);
//    		Capabilities.isDebugger && Application.log("> Nest -> DatabaseService Execute QUERY: " + _sqlStatement.text);
			stmt.execute();
		} catch ( e:SQLError ) {
			if( e.errorID == 3119 ) { // Error #3119: Database file is currently locked.
			  setTimeout( function ():void { Execute( stmt ); }, 100 );
			} else {
        trace("> Nest > DatabaseService -> Execute SQLError:", e.details + ":" + e.getStackTrace());
				if(_sqlConnection != null && _sqlConnection.inTransaction) {
              _sqlConnection.rollback();
				}
			}
		}
	}
	
	private function Handler_SQLStatement_Result( event:SQLEvent ):void {
//		Capabilities.isDebugger && Application.log("Handler_SQLStatement_Result");
		event.currentTarget.removeEventListener( SQLEvent.RESULT, Handler_SQLStatement_Result );
		this.dispatchEvent( new Event(EVENT_EXECUTE_COMPLETE) );
	}

	//==================================================================================================
	private function FillStatementParametersFromObject(statement:SQLStatement, data:Object):Array {
	//==================================================================================================
		const params : Object = statement.parameters;
		const attributes : Array = GetObjectAttributes(data);
		var	key:String = "", counter:uint = 0;
		if(attributes.length) for each (key in attributes) params[counter++] = data[key];
		else for (key in data) {
			attributes.push(key);
			params[counter++] = data[key];
		}
		return attributes;
	}

	//==================================================================================================
	private function GetObjectAttributes(instance:Object):Array {
	//==================================================================================================
		const className		: String 	= getQualifiedClassName(instance);
		const customClass	: Boolean 	= className != "Object";
		var attributes 		: Array 	= customClass ? _objectPropertyNamesCache[className] : [];
		if(attributes == null) {
			attributes = GetPropertyNames(instance);
			_objectPropertyNamesCache[className] = attributes;
		}
		return attributes;
	}

	//==================================================================================================
	private function GetPropertyNames(instance:Object):Array {
	//==================================================================================================
		const typeDef		: XML = describeType( instance );
		const props			: Array = [];
		const variablesList	: XMLList = typeDef..variable;
		var variableXML		: XML;
		for ( var i:int = 0, j:uint = variablesList.length()-1; i <= j; i++ ) {
			variableXML = variablesList[i] as XML;
			props.push( variableXML.@name );
		}
		return props;
	}

	public function set language(value:String):void { DatabaseQuery.AND_LANGUAGE[3] = value; }

	private static const _instance:DatabaseService = new DatabaseService();
	public function DatabaseService() { if(_instance != null) throw new Error("This is a singleton class, use .getInstance()"); }
	public static function getInstance():DatabaseService { return _instance; }

}
}