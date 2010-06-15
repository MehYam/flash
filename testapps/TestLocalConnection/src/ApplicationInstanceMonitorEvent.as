package
{
	import flash.events.Event;

	public class ApplicationInstanceMonitorEvent extends Event
	{
		public static const INSTANCE_STARTING:String = "instanceStarting";
		public static const INSTANCE_EXISTS:String = "instanceExists";
		public static const SEND_ERROR:String = "sendError";
		public function ApplicationInstanceMonitorEvent(type:String)
		{
			super(type);
		}
	}
}