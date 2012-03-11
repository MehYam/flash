package data
{
	import mx.collections.ArrayList;

	public final class ConnectionType
	{
		private var _type:String;
		
		static public const SERVER:ConnectionType = new ConnectionType("server");
		static public const CLIENT:ConnectionType = new ConnectionType("client");
		static public const BOTH:ConnectionType = new ConnectionType("both");
		
		static public const SOURCE_TYPES:ArrayList = new ArrayList([SERVER, CLIENT]);
		static public const DEST_TYPES:ArrayList = new ArrayList([SERVER, CLIENT, BOTH]);
		
		public function toString():String { return _type; }
		public function ConnectionType(type:String)
		{
			_type = type;
		}
	}
}