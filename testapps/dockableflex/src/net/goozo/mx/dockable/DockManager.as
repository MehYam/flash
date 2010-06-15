package net.goozo.mx.dockable
{
	import flash.events.MouseEvent;
	
	import mx.core.Container;
	import mx.core.UIComponent;

[ExcludeClass]

	public class DockManager
	{
		public static const CLOSABLEPANEL:int = 0;
		public static const DOCKABLEPANEL:int = 1;
		public static const FLOATPANEL:int = 2;

		
		public static const LEFT:String = "dockLeft";
		public static const RIGHT:String = "dockRight";
		public static const TOP:String = "dockTop";
		public static const BOTTOM:String = "dockBottom";
		public static const WHOLE:String = "dockWhole";
		public static const FLOAT:String = "dockFloat";

		public static const OUTSIDE:String = "outside";
			
		public static const DRAGTAB:String = "dragTab";
		public static const DRAGPANNEL:String = "dragPannel";
	
		private static var _impl:DockManagerImpl = null;
		private static function get impl():DockManagerImpl
		{
			if (_impl == null)
			{
				_impl = new DockManagerImpl();
			}
			return _impl;
		}

		public static function get isDocking():Boolean
		{
			return impl.isDocking;
		}
		
		public static function get explicitDockCanvas():Container
		{
			return impl.explicitDockCanvas;
		}
		public static function set explicitDockCanvas(value:Container):void
		{
			impl.explicitDockCanvas = value;
		}
						
		public static function doDock(dragInitiator:UIComponent, dockSource:DockSource, e:MouseEvent):Boolean
		{
			return impl.doDock(dragInitiator, dockSource, e);
		}
	}
}