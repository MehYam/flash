package data
{
	import mx.collections.ArrayList;

	public final class ConnectionType
	{
		static private const s_lookup:Object = {};
		static public const SERVER:ConnectionType = new ConnectionType("server", CONSTRUCTOR_LOCK);
		static public const CLIENT:ConnectionType = new ConnectionType("client", CONSTRUCTOR_LOCK);
		static public const BOTH:ConnectionType = new ConnectionType("both", CONSTRUCTOR_LOCK);
		
		static public const SOURCE_TYPES:ArrayList = new ArrayList([SERVER, CLIENT]);
		static public const DEST_TYPES:ArrayList = new ArrayList([SERVER, CLIENT, BOTH]);

		static public function fromString(string:String):ConnectionType // for serialization only
		{
			return s_lookup[string];
		}
		private var _type:String;
		public function toString():String { return _type; }
		public function ConnectionType(type:String, constructorLock:Class)
		{
			if (constructorLock != CONSTRUCTOR_LOCK) throw "constructed from the class factory only";
			if (fromString(type)) throw "duplicate ConnectionType";
			
			_type = type;
			
			s_lookup[type] = this;
		}
	}
}

final internal class CONSTRUCTOR_LOCK {}