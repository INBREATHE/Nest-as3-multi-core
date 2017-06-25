package nest.services.database
{
	public final class DatabaseTable
	{
		private var 
			_tableName	: String
		,	_tableClass	: Class;
		
		public function DatabaseTable(tableName:String, tableClass:Class)
		{
			_tableName = tableName;
			_tableClass = tableClass;
		}

		public function get tableClass():Class { return _tableClass; }
		public function get tableName():String { return _tableName; }

	}
}