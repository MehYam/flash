package karnold.utils
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;

	//
	// This thing queues up calls to an asynchronous SQL store and invokes them serially, allowing
	// callbacks to be called with the result.  Multiple instances of this targetting the same
	// database and tables should theoretically work, although this thing currently just swallows
	// errors.  Not sure this is the best way to integrate with SQLite from AS3 (first attempt at 
	// something like this), but it's simple and safe.
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
			
			queueCommand(cmd, null);
		}
		public function readTable(name:String, callback:Function):void
		{
			queueCommand("SELECT * FROM " + name, callback);
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
			queueCommand(cmd, null);
		}
		private function onSQLOpen(e:SQLEvent):void
		{
			_sqls.sqlConnection = _sqlc;
			runNext();
		}
		private var _queue:Vector.<Command> = new Vector.<Command>;
		private function queueCommand(cmd:String, callback:Function):void
		{
			_queue.push(new Command(cmd, callback));
			runNext();
		}
		//	sqls.text = "DELETE FROM test_table WHERE id="+dp[dg.selectedIndex].id;
		//	sqls.text = "INSERT INTO test_table (first_name, last_name) VALUES('"+first_name.text+"','"+last_name.text+"');";
		private function runNext():void
		{
			trace("running next w/", _queue.length, "remaining");
			if (_queue.length && _sqls.sqlConnection && !_sqls.executing)
			{
				const command:Command = _queue[0];
				_sqls.text = command.cmdText;
				_sqls.execute();
			}
		}
		private function onSQLError(e:SQLErrorEvent):void
		{
			trace("error:", e);
			
			_queue.shift();
			runNext();
		}
		private function onSQLResult(e:SQLEvent):void
		{
			const data:Array = _sqls.getResult().data;
			trace("data:", data);
			
			const command:Command = _queue.shift();
			if (command.callback != null)
			{
				command.callback(data);
			}
			runNext();
		}
	}
}

internal final class Command
{
	public var cmdText:String;
	public var callback:Function;
	public function Command(cmdText:String, callback:Function)
	{
		this.cmdText = cmdText;
		this.callback = callback;
	}
}