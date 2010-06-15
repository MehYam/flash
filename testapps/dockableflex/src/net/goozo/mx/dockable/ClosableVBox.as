package net.goozo.mx.dockable
{
	import mx.containers.VBox;
	
	public class ClosableVBox extends VBox implements IDockableTabChild
	{
		public function ClosableVBox()
		{
			super();
		}
		public function get closeTabEnabled():Boolean
		{
			return true;
		}
		public function closeTab():Boolean
		{
			return true;
		}
	}
}
