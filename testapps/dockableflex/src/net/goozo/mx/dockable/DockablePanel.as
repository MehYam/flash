package net.goozo.mx.dockable
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import mx.effects.AnimateProperty;
	import mx.effects.Move;
	import mx.effects.Resize;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.effects.easing.Quartic;
	
[IconFile("DockablePanel.png")]

	/**
	 *  A DockablePanel instance is always in a DockableHDivideedBox or
	 *  DockableVDivideedBox. It can be dragged and dropped in to another
	 *  DockableDivideedBox. Or it can be dragged and released at some empty
	 *  space, then the DockablePanel will be removed and a FloatPanel that
	 *  cantains all its children will be created.
	 */
	public class DockablePanel extends ClosablePanel
	{		
		override public function get panelType():int
		{
			return DockManager.DOCKABLEPANEL;
		}
		
		private var dragStarter:DragStarter = null;
		
		/**
		 *  floatEnabled is true when its childContainer is floatEnabled
		 *  and <code>lockPanel</code> is set to false.
		 */
		override public function get floatEnabled():Boolean
		{
			if (dockContainer != null)
			{
				return !lockPanel && dockContainer.floatEnabled;
			}
			return false;
		}
		
		/**
		 *  Constructor
		 *  @param	fromChild If fromChild is not an IDockableContainer instance, 
		 *  a new DockableTabNavigator will be created, and put it as its first
		 *  tab child.
		 */
		public function DockablePanel(fromChild:Container = null)
		{
			super(fromChild);
		}
		
		/**
		 *  @private
		 */
		override protected function childrenCreated():void 
		{
			super.childrenCreated();

			if (dragStarter == null)
			{
				dragStarter = new DragStarter(titleBar);
			}			
			dragStarter.startListen(startDragDockPanel);
		}

		private function startDragDockPanel(e:MouseEvent):void
		{  
			var targetTabNav:DockableTabNavigator = null;
			var dockId:String = "";
			if (dockContainer is DockableTabNavigator)
			{
				targetTabNav = (dockContainer as DockableTabNavigator)
				dockId = targetTabNav.dockId;
			}
            var dockSource:DockSource = new DockSource(DockManager.DRAGPANNEL, targetTabNav, dockId);
            dockSource.targetPanel = this;
            
            dockSource.multiTabEnabled = multiTabEnabled;
			dockSource.floatEnabled = floatEnabled;
			dockSource.autoCreatePanelEnabled = autoCreatePanelEnabled;
			
			dockSource.lockPanel = lockPanel;
			
            DockManager.doDock(this, dockSource, e);
		}

		/**
		 *  @private
		 */
		internal function dockAsk(source:DockSource, target:UIComponent, position:String):Boolean
		{
			if ((target!= this || source.targetPanel!= this) 
			 && (dockContainer.numChildren!= 1 || source.targetTabNav!= dockContainer)
			){
				return true;
			}
			else
			{
				return false;
			}
		}
	}
}