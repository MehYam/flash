package
{
	import flash.events.Event;

	public class SomeEvent extends Event
	{
		public static const EVENT1:String = "e1";
		public static const EVENT2:String = "e2";
		
		public function SomeEvent(type:String)
		{
			super(type);
		}
	}
}