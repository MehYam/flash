package ui
{
	import flash.events.Event;
	
	public class GlobalUIEvent extends Event
	{
		public static const PURCHASE_MADE:String = "GlobalUIEvent.purchaseMade";
		
		public var arg:Object;
		public function GlobalUIEvent(type:String, arg:Object = null)
		{
			super(type, false, false);
			
			this.arg = arg;
		}
	}
}