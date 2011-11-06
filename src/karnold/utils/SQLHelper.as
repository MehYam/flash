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
		static public const TYPE_BOOLEAN:String = "INTEGER";  // implemented as 0/1
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
		 * @param autoID - sets up an auto-incrementing ID field on records, does not read the ID field when writing
		 * Each object requires a unique .id value.
		 * 
		 */
		public function createTable(name:String, fields:Array, autoID:Boolean):void
		{
			_tableFields[name] = new TableEntry(fields, autoID);
			
			var cmd:String = "CREATE TABLE IF NOT EXISTS " + name + " ( id INTEGER PRIMARY KEY";
			if (autoID)
			{
				cmd += " AUTOINCREMENT";
			}
			for each (var field:Object in fields)
			{
				cmd += ", " + field.name + " " + field.type;
			}
			cmd += ")";
			
			queueCommand(cmd, null);
		}
		public function clearTable(name:String):void
		{
			queueCommand("DELETE FROM " + name, null);
		}
		public function deleteTable(name:String):void
		{
			queueCommand("DROP TABLE " + name, null);
		}
		public function readTable(table:String, callback:Function):void
		{
			queueCommand("SELECT * FROM " + table, callback);
		}
		public function readTableForColumn(table:String, forColumn:String, forValue:int, callback:Function):void
		{
			queueCommand("SELECT * FROM " + table + " WHERE " + forColumn + "=" + forValue, callback);
		}
		public function writeRecord(tableName:String, obj:Object):void
		{
			const table:TableEntry = _tableFields[tableName];
			if (!table)
			{
				throw Error("Unrecognized table " + tableName);
			}
			var cmdFields:Vector.<String> = new Vector.<String>;
			var cmdValues:Vector.<String> = new Vector.<String>;
			if (!table.autoID)
			{
				cmdFields.push('"id"');
				cmdValues.push(obj.id);
			}
			for each (var field:Object in table.fields)
			{
				cmdFields.push('"' + field.name + '"');

				const val:String = obj[field.name] || "";
				cmdValues.push(field.type == TYPE_TEXT ? ('"' + val + '"') : val);
			}
			var cmd:String = table.autoID ? "INSERT INTO " : "INSERT OR REPLACE INTO ";
			cmd += tableName + " (" + cmdFields.join(", ") + ")";;
			if (cmdValues.length)
			{
				cmd += " VALUES (" + cmdValues.join(", ") + ")";
			}
			queueCommand(cmd, null);
		}
		public function deleteRecord(tableName:String, objID:int):void
		{
			var cmd:String = "DELETE FROM " + tableName + " WHERE id=" + objID;
			queueCommand(cmd, null);
		}
		public function deleteRecordsFor(tableName:String, column:String, value:int):void
		{
			var cmd:String = "DELETE FROM " + tableName + " WHERE " + column + "=" + value;
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
			++_total;
			_queue.push(new Command(cmd, callback));
			runNext();
		}
		private var _total:uint = 0;
		private var _errors:uint = 0;
		private function runNext():void
		{
			Util.info("SQLHelper.runNext", _queue.length, "queued, so far", _total, ", errors", _errors);
			if (_queue.length && _sqls.sqlConnection && !_sqls.executing)
			{
				const command:Command = _queue[0];
				_sqls.text = command.cmdText;
				_sqls.execute();
			}
		}
		private function onSQLError(e:SQLErrorEvent):void
		{
			const command:Command = _queue.shift();
			Util.info("onSQLError for", command.cmdText, "errors", ++_errors);
			Util.info(e, e.error);
			
			runNext();
		}
		private function onSQLResult(e:SQLEvent):void
		{
			const data:Array = _sqls.getResult().data;
			const command:Command = _queue.shift();

			Util.info("onSQLResult", (data ? data.length : "null"), "results for", command.cmdText);
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

internal final class TableEntry
{
	public var fields:Array;
	public var autoID:Boolean;
	public function TableEntry(fields:Array, autoID:Boolean)
	{
		this.fields = fields;
		this.autoID = autoID;
	}
}