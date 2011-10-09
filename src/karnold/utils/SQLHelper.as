package karnold.utils
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	final public class SQLHelper
	{
		private const _sqlc:SQLConnection = new SQLConnection();
		private const _sqls:SQLStatement = new SQLStatement();
		
		static public const TYPE_NULL:String = "NULL";
		static public const TYPE_INTEGER:String = "INTEGER";
		static public const TYPE_REAL:String = "REAL";
		static public const TYPE_TEXT:String = "TEXT";
		static public const TYPE_BLOB:String = "BLOB";
		public function SQLHelper()
		{
			// first we need to set the file class for our database (in this example test.db). If the Database doesn't exists it will be created when we open it.
			var db:File = File.applicationStorageDirectory.resolvePath("custapp.db");
			
			// after we set the file for our database we need to open it with our SQLConnection.
			_sqlc.openAsync(db);
			
			// we need to set some event listeners so we know if we get an sql error, when the database is fully opened and to know when we recive a resault from an sql statment. The last one is uset to read data out of database.
			_sqlc.addEventListener(SQLEvent.OPEN, onSQLOpen);
			_sqlc.addEventListener(SQLErrorEvent.ERROR, onSQLError);
			_sqls.addEventListener(SQLErrorEvent.ERROR, onSQLError);
			_sqls.addEventListener(SQLEvent.RESULT, onSQLResult);
		}
		
		private var _tableFields:Object = {};
		/**
		 * 
		 * @param name - name of the table in the database
		 * @param fields - array of { name: fieldName, type: fieldType } objects where fieldType is one of the TYPE_* constants.
		 * Each object requires a unique .id value.
		 * 
		 */
		public function createTable(name:String, fields:Array):void
		{
			_tableFields[name] = fields;
			
			var cmd:String = "CREATE TABLE IF NOT EXISTS " + name + " ( id INTEGER PRIMARY KEY";
			for each (var field:Object in fields)
			{
				cmd += ", " + field.name + " " + field.type;
			}
			cmd += ")";
			
			queueCommand(cmd);
		}
		public function writeRecord(tableName:String, obj:Object):void
		{
			const fields:Array = _tableFields[tableName];
			if (!fields)
			{
				throw Error("Unrecognized table " + tableName);
			}
			var cmd:String = "INSERT OR REPLACE INTO " + tableName + " (\"id\"";
			var cmdValues:String = "VALUES (" + obj.id;
			for each (var field:Object in fields)
			{
				cmd += ", \"" + field.name + "\"";
				cmdValues += ", ";
				const val:String = obj[field.name];
				if (field.type == TYPE_TEXT)
				{
					cmdValues += "\"" + val + "\"";
				}
				else
				{
					cmdValues += val;
				}
			}
			cmd += ")" + cmdValues + ")";
			queueCommand(cmd);
		}
		private function onSQLOpen(e:SQLEvent):void
		{
			_sqls.sqlConnection = _sqlc;
			runNext();
		}
		private var _queue:Vector.<String> = new Vector.<String>;
		private function queueCommand(cmd:String):void
		{
			_queue.push(cmd);
			runNext();
		}
		//"SELECT * FROM test_table"
		//	sqls.text = "DELETE FROM test_table WHERE id="+dp[dg.selectedIndex].id;
		//	sqls.text = "INSERT INTO test_table (first_name, last_name) VALUES('"+first_name.text+"','"+last_name.text+"');";
		private function runNext():void
		{
			trace("running next w/", _queue.length, "remaining");
			if (_queue.length && _sqls.sqlConnection && !_sqls.executing)
			{
				_sqls.text = _queue.shift();
				_sqls.execute();
			}
		}
		private function onSQLError(e:SQLErrorEvent):void
		{
			trace("error:", e);
			runNext();
		}
		private function onSQLResult(e:SQLEvent):void
		{
			var data:Array = _sqls.getResult().data;
			trace("data:", data);
			
			runNext();
		}
	}
}