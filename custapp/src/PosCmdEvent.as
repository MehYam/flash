package
{
	import flash.events.Event;
	
	public final class PosCmdEvent extends Event
	{
		static public const COMPLETE:String = "PosCmdEvent.COMPLETE";
		static public const ERROR:String = "PosCmdEvent.ERROR";
		static public const OUTPUT:String = "PosCmdEvnet.OUTPUT";
		
		private var _result:String;
		public function PosCmdEvent(type:String, result:String)
		{
			super(type, false, false);
			_result = result;
		}
		public function get result():String
		{
			return _result;
		}
	}
}