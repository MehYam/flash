package net.goozo.mx.dockable
{
	import mx.containers.HBox;
	
	public class DockableHBox extends HBox implements IDockableContainer
	{
		public function DockableHBox()
		{
		}
		protected var _floatEnabled:Boolean;
		public function get floatEnabled():Boolean
		{
			return _floatEnabled;
		}
		public function set floatEnabled(value:Boolean):void
		{
			_floatEnabled = value;
		}
		public function closeChild():void
		{
			
		}
		public function set panelType(value:int):void
		{
			
		}
	}
}
