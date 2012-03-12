package net
{
	public final class SocketStatus
	{
		static public const READY:SocketStatus = new SocketStatus("ready", CONSTRUCTOR_LOCK);
		static public const CONNECTING:SocketStatus = new SocketStatus("connecting", CONSTRUCTOR_LOCK);
		static public const CONNECTED:SocketStatus = new SocketStatus("connected", CONSTRUCTOR_LOCK);
		static public const CLOSED:SocketStatus = new SocketStatus("closed", CONSTRUCTOR_LOCK);

		private var _type:String;
		public function toString():String { return _type; }
		public function SocketStatus(type:String, constructorLock:Class)
		{
			if (constructorLock != CONSTRUCTOR_LOCK) throw "constructed from the class factory only";
			
			_type = type;
		}
	}
}

final internal class CONSTRUCTOR_LOCK {}