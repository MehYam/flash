package data 
{
	import net.ClientSocket;

	public final class ConnectionItem
	{
		static private var _instances:int = 0;
		
		public function get running():Boolean { return _running; }
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
		
		private var _running:Boolean = false;
		public function set running(r:Boolean):void
		{
			if (_running != r)
			{
				if (r)
				{
					// fire up all the connections
				}
				else
				{
					// close all the connections
				}
				_running = r;
			}
		}
		
		private var _sourceClient:ClientSocket;
		private var _destClient:ClientSocket;
	}
}