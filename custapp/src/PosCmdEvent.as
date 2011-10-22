package
{
	import flash.events.Event;
	
	public final class PosCmdEvent extends Event
	{
		static const public COMPLETE:String = "PosCmdEvent.COMPLETE";
		static const public ERROR:String = "PosCmdEvent.ERROR";
		
		public var result:String;
		public function PosCmdEvent(type:String)
		{
			super(type, false, false);
		}
	}
}