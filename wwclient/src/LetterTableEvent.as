package
{
	import flash.events.Event;
	
	public class LetterTableEvent extends Event
	{
		public static const PATH_CHANGED:String = "PATH_CHANGED";
		public function LetterTableEvent(type:String)
		{
			super(type, false, false);
		}
	}
}