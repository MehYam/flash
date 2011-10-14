package ui
{
	import flash.events.Event;
	
	// catch these as Event.COMPLETE 
	public final class DialogEvent extends Event
	{
		static public const CLOSE_BUTTON_CAUSE:String = "DialogEvent.closeButton";

		// this will either be CLOSE_BUTTON above, or the text of whatever button was clicked on the dialog
		public function get cause():String { return _cause; }

		private var _cause:String;
		public function DialogEvent(cause:String)
		{
			super(Event.COMPLETE, false, false);
			_cause = cause;
		}
	}
}