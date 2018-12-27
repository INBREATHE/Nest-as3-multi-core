/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.database
{
import flash.utils.Dictionary;
import flash.utils.describeType;

import nest.entities.application.Application;

public final class DatabaseQuery
{
	private static const VAR_TO_DB:Dictionary = new Dictionary()
	{
		VAR_TO_DB["String"] 	= " TEXT";
		VAR_TO_DB["int"] 		= " INTEGER";
		VAR_TO_DB["uint"] 		= " INTEGER";
		VAR_TO_DB["Boolean"] 	= " INTEGER";
		VAR_TO_DB["Number"] 	= " REAL";
		VAR_TO_DB["Object"] 	= " OBJECT";
	}

	public static const
		CREATE_TABLE	: String 	= "CREATE TABLE IF NOT EXISTS "
	,	SELECT_FROM		: String 	= "SELECT * FROM "
	,	COUNT_FROM		: String 	= "SELECT COUNT(*) FROM "
	,	INSERT_INTO		: String 	= "INSERT INTO "
	,	REPLACE_INTO	: String 	= "REPLACE INTO "
	,	UPDATE			  : String 	= "UPDATE "
	,	DELETE_FROM		: String 	= "DELETE FROM "

	,	LIMIT			: String 	= " LIMIT "
	,	WHERE			: String 	= " WHERE "
	,	VALUES			: String 	= " VALUES"
	,	SET				: String	= " SET "
	,	COUNT			: String 	= "COUNT(*)"
	,	ROWID			: Array 	= ["rowid = ", ""]
	,	ORDER_BY		: Array 	= [" ORDER BY ", "", ""]
	,	ORDER_DESC		: String	= " DESC "
	,	ORDER_ASC		: String	= " ASC "

	,	AND_LANGUAGE 				: Array = ["0_TEXT"," AND ","lng='", "3", "'", ""]

	,	COUNT_FROM_TABLE_WHERE		: Array = [ COUNT_FROM, 	"1_TABLE_NAME", WHERE, "3_CRITERIA" ]
	,	SELECT_FROM_TABLE_WHERE		: Array = [ SELECT_FROM, 	"1_TABLE_NAME", WHERE, "3_CRITERIA" ]
	,	DELETE_FROM_TABLE_WHERE		: Array = [ DELETE_FROM, 	"1_TABLE_NAME", WHERE, "3_CRITERIA" ]
	,	UPDATE_TABLE_PARAMS_WHERE	: Array = [ UPDATE, 		"1_TABLE_NAME", SET, "3_PARAMS", WHERE, "5_CRITERIA"]
	,	CREATE_TABLE_FROM_CLASS		: Array = [ CREATE_TABLE, 	"1_TABLE_NAME", "2_VARIABLES_FROM_CLASS"]
	,	INSERT_DATA_TO_TABLE		: Array = [ INSERT_INTO, 	"1_TABLE_NAME", "(", "3_PARAMS", ") VALUES(", "5_VALUES", ");" ]
	;

	public static function RowID(index:uint):String { ROWID[1] = String(index); return ROWID.join(""); }
	public static function LimitBy(index:uint):String { return LIMIT + index; }
	public static function OrderBy(value:String, type:String = null):String { 
		ORDER_BY[1] = String(value); 
		ORDER_BY[2] = type || ORDER_DESC; 
		return ORDER_BY.join(""); 
	}

	public static function DeleteFromTableWhere(table:String, criteria:String):String {
		DELETE_FROM_TABLE_WHERE[1] = table;
		DELETE_FROM_TABLE_WHERE[3] = criteria;
		return DELETE_FROM_TABLE_WHERE.join("");
	}

	public static function CreateTableFromClass(tableName:String, classRef:Class):String {
		const classXML		: XML = describeType(classRef);
		const variablesList	: XMLList = classXML..variable;
		var variableXML		: XML,
			classVariables	: Array = ["( "],
			primaryKeyExist	: Boolean = false,
			primaryKeyFound	: Boolean = false,
			variableMeta	  : XMLList,
			variableMeta1	  : XML,
			variableName	  : String = "",
			variableType	  : String = "",
			variableDB		  : Array = ["name", "type", ", "];
		
//		Capabilities.isDebugger && Application.log( "CreateTableFromClass variables count = " + variablesList.length());
		for (var i:int = 0, j:uint = variablesList.length()-1; i <= j; i++)
		{
			variableXML = variablesList[i] as XML;
			primaryKeyExist = false;
//			Capabilities.isDebugger && Application.log("T1", primaryKeyFound, variableXML );
			if(primaryKeyFound == false)
			{
				variableMeta = variableXML.metadata;
//				Capabilities.isDebugger && Application.log("T2 variableMeta = ", variableMeta != null );
				variableMeta1 = variableMeta[0];
				if(variableMeta1) {
					primaryKeyExist = variableMeta1.@name == "PrimaryKey";
					primaryKeyFound = true;
				}
			}
			variableName = variableXML.@name;
//			Capabilities.isDebugger && Application.log("T2 variableName = ", variableName );
			variableType = VAR_TO_DB[variableXML.@type];
			variableDB[0] = variableName;
			variableDB[1] = (primaryKeyFound && primaryKeyExist) ? (variableType + " PRIMARY KEY") : variableType;
			if(i == j) variableDB[2] = "";

			classVariables.push(variableDB.join(""));
		}
		classVariables.push(" )");
//		Capabilities.isDebugger && Application.log( "CreateTableFromClass classVariables: ", classVariables);
		CREATE_TABLE_FROM_CLASS[1] = tableName;
		CREATE_TABLE_FROM_CLASS[2] = classVariables.join("");
		return CREATE_TABLE_FROM_CLASS.join("");
	}

	public static function QueryWithLanguage(text:String):String {
		const indexOfOrder:int = text.indexOf(ORDER_BY[0]);
		if(indexOfOrder > 0) {
			AND_LANGUAGE[0] = text.substr(0, indexOfOrder);
			AND_LANGUAGE[5] = text.substr(indexOfOrder);
		} else {
			AND_LANGUAGE[0] = text;
			AND_LANGUAGE[5] = "";
		}
		return AND_LANGUAGE.join("");
	}

	public static function SelectFromTable(table:String, criteria:String):String {
		SELECT_FROM_TABLE_WHERE[1] = table;
		SELECT_FROM_TABLE_WHERE[3] = criteria;
		return SELECT_FROM_TABLE_WHERE.join("");
	}

	public static function CountFromTable(table:String, criteria:String):String {
		COUNT_FROM_TABLE_WHERE[1] = table;
		COUNT_FROM_TABLE_WHERE[3] = criteria;
		return COUNT_FROM_TABLE_WHERE.join("");
	}

	public static function UpdateTableParamsWhere(table:String, params:Array, criteria:String):String {
		UPDATE_TABLE_PARAMS_WHERE[1] = table;
		UPDATE_TABLE_PARAMS_WHERE[3] = (params.length > 1 ? params.join("=?,") : params[0]) + "=?"
		UPDATE_TABLE_PARAMS_WHERE[5] = criteria;
		return UPDATE_TABLE_PARAMS_WHERE.join("");
	}

	public static function InsertDataObjectToTable(attributes:Array, table:String):String {
		INSERT_DATA_TO_TABLE[1] = table;
		INSERT_DATA_TO_TABLE[3] = attributes.join(",");
		INSERT_DATA_TO_TABLE[5] = "@" + attributes.join(",@");
		return INSERT_DATA_TO_TABLE.join("");
	}

	public static function InsertDataStringToTable(data:String, table:String):String {
		const obj:Object = JSON.parse(data);
		const params:Array = [], values:Array = [];
		var key:String, value:*;
		for (key in obj) {
			value = obj[key];
			if(value == false) value = 0;
			else if(value == true) value = 1;
			params.push(key);
			values.push(value);
		}
		INSERT_DATA_TO_TABLE[1] = table;
		INSERT_DATA_TO_TABLE[3] = params.join(",");
		INSERT_DATA_TO_TABLE[5] = "'" + values.join("','") + "'";
		return INSERT_DATA_TO_TABLE.join("");
	}
}
}