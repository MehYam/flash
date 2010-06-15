package
{
	import flash.events.Event;

	public class TabDropEvent extends Event
	{
		public static const TAB_DROP:String = "tabDrop";
		
		public var title:String
		public function TabDropEvent(type:String, title:String)
		{
			super(type, false, false);
			this.title = title;
		}
		
	}
}