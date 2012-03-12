package net
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public final class ClientSocketEvent extends Event
	{
		static public const STATUS_CHANGE:String = "ClientSocketEvent.STATUS_CHANGE";
		static public const DATA:String = "ClientSocketEvent.DATA";
		
		public var text:String;
		public var data:ByteArray;
		public function ClientSocketEvent(type:String)
		{
			super(type, false, false);
		}
	}
}