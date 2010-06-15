package de.aggro.components
{
	import flash.events.Event;

	public class CollapsableTitleWindowEvent extends Event
	{
		public static var CLOSE:String = "close";
		public static var EXPAND:String = "expand";
		public static var COLLAPSE:String = "collapse";
		public static var MAXIMIZE:String = "maximize";
		public static var MINIMIZE:String = "minimize";
		public static var RESIZE:String = "resizeWindow";
		
		public function CollapsableTitleWindowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}