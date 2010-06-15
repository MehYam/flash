package net.goozo.mx.dockable
{
	import flash.events.Event;

	/**
	 *  Represents events that are dispatched when the selected child is
	 *  changed in a DockableTabNavigator
	 */
	public class ChildChangeEvent extends Event
	{
		/**
		 *  Represents events that are dispatched when the selected child is
		 *  changed in a DockableTabNavigator
		 */
		public static const CHILD_CHANGE:String = "childChange";
		
		/**
		 *  newTitle is the title of the new selected child.
		 */
		public var newTitle:String = "";
		/**
		 *  If the new selected child is closable, show the close button.
		 */
		public var useCloseButton:Boolean = false;
		
		/**
		 *  Constructor
		 *  @param type The event type;indicates the action that caused the event.
		 *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
		 *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
		 */
		public function ChildChangeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}