package data 
{
	public final class ConnectionItem
	{
		static private var _instances:int = 0;
		
		public var running:Boolean;
		public var name:String = "Entry" + ++_instances;
		public var status:String = "--";

		public var sourceType:ConnectionType = ConnectionType.CLIENT
		public var sourceIP:String = "localhost";
		public var sourcePort:int;
		
		public var destType:ConnectionType = ConnectionType.CLIENT;
		public var destIP:String = "localhost";
		public var destPort:int;
		public var destServerPort:int;
		
		public var stats:String = "--";
		public var buffer:String = "--";
	}
}