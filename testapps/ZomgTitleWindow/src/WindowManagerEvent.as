package
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	public class WindowManagerEvent extends MouseEvent
	{
		public static const DRAG_START:String = "snapDragStart";
		public static const RESIZE_START:String = "snapResizeStart";
		public static const SNAP_DONE:String = "snapDone";

		public var object:DisplayObject;		
		public function WindowManagerEvent(type:String, obj:DisplayObject = null)
		{
			super(type, false, false);
			
			this.object = obj;
		}
	}
}