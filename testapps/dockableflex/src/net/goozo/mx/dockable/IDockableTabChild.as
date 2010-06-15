package net.goozo.mx.dockable
{
	import mx.core.IContainer;
	
	
	/**
	 *  Implemented the IDockableTabChild interface if you need a closable
	 *  tab child in the DockableTabNavigator
	 */
	public interface IDockableTabChild extends IContainer
	{
		/**
		 *  Tell the parent DockableTabNavigator whether this child can be closed
		 *  or not. If true, the ClosablePanel will show the close button.
		 *  @return return true if this child can be closed.
		 */
		function get closeTabEnabled():Boolean;
		/**
		 *  DockableTabNavigator call this function to close its child if
		 *  the user clicks the close button.
		 *  @return If true, the parent will remove this child.
		 *  If false, the parent will do nothing.
		 */
		function closeTab():Boolean;
	}
}