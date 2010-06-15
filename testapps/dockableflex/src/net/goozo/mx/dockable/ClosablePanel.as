package net.goozo.mx.dockable
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import mx.containers.TitleWindow;
	import mx.core.Container;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;



	/**
	 *  The ClosablePanel class is the base class of DockablePanel and FloatPanel.
	 */
	public class ClosablePanel extends TitleWindow
	{
		public function get panelType():int
		{
			return DockManager.CLOSABLEPANEL;
		}
		
		/**
		 *  Set lockPanel to true so that the panel can not
		 *  be converted to FloatPanel.(If it's a DockablePanel)
		 *  And if lockPanel is set to true, the panel won't
		 *  be removed by the system even if all it's children have be removed.
		 */
		public var lockPanel:Boolean =  false;

		/**
		 *  @private
		 */
		protected var dockContainer:IDockableContainer = null;

		/**
		 *  @copy DockableTabNavigator#floatEnabled
		 */
		public function get floatEnabled():Boolean
		{
			if (dockContainer!= null)
			{
				return dockContainer.floatEnabled;
			}
			return false;
		}
		/**
		 *  @copy DockableTabNavigator#multiTabEnabled
		 */
		public function get multiTabEnabled():Boolean
		{
			if (dockContainer!= null && dockContainer is DockableTabNavigator)
			{
				return (dockContainer as DockableTabNavigator).multiTabEnabled;
			}
			return false;
		}
		/**
		 *  @copy DockableTabNavigator#autoCreatePanelEnabled
		 */
		public function get autoCreatePanelEnabled():Boolean
		{
			if (dockContainer!= null && dockContainer is DockableTabNavigator)
			{
				return (dockContainer as DockableTabNavigator).autoCreatePanelEnabled;
			}
			return false;
		}
		
		/**
		 *  Constructor
		 *  @param	fromChild If fromChild is not an IDockableContainer instance, 
		 *  a new DockableTabNavigator will be created, and put it as its first
		 *  tab child.
		 */
		public function ClosablePanel(fromChild:Container = null)
		{
			super();
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			addEventListener(CloseEvent.CLOSE, handleClose);
			
			if (fromChild != null)
			{
				if (fromChild is IDockableContainer)
				{
					addChild(fromChild);
					if (fromChild is DockableTabNavigator && DockableTabNavigator(fromChild).selectedChild)
					{
						//force it to dispatch a ChildChangeEvent
						DockableTabNavigator(fromChild).selectedChild = DockableTabNavigator(fromChild).selectedChild;
					}
				}
				else
				{
					var newTabNav:DockableTabNavigator = new DockableTabNavigator();
					addChild(newTabNav);
					if (fromChild.parent!= null && fromChild.parent is DockableTabNavigator)
					{
						var oldTabNav:DockableTabNavigator = DockableTabNavigator(fromChild.parent);
						newTabNav.dockId = oldTabNav.dockId;
						newTabNav.autoCreatePanelEnabled = oldTabNav.autoCreatePanelEnabled;
						newTabNav.floatEnabled = oldTabNav.floatEnabled;
						newTabNav.multiTabEnabled = oldTabNav.multiTabEnabled;
					}			
					addChild(fromChild);					
				}	
			}
		}
		/**
		 * @private
		 */
		override public function addChild(child:DisplayObject):DisplayObject
		{
			return addChildAt(child, -1);
		}
		/**
		 * @private
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{ 
			if (dockContainer != null)
			{
				if (index == -1)
				{
					return  dockContainer.addChild(child);
				}
				else
				{
					return  dockContainer.addChildAt(child, index);
				}
				
			}
			else
			{
				if (child is IDockableContainer)
				{
					dockContainer = IDockableContainer(child);
					super.addChildAt(dockContainer as DisplayObject, 0);
					title = (dockContainer as Container).label;
				}
				else
				{
					dockContainer = new DockableTabNavigator();
					super.addChildAt(dockContainer as DisplayObject, 0);
					dockContainer.addChildAt(child, 0);
					title = Container(child).label;
				}
				dockContainer.panelType = panelType;
				dockContainer.percentWidth = 100;
				dockContainer.percentHeight = 100;
				dockContainer.addEventListener(ChildChangeEvent.CHILD_CHANGE, handleChangeChild);
				
				return child;
			}		
		}
		protected function handleChangeChild(e:ChildChangeEvent):void
		{
			title = e.newTitle;
			showCloseButton = e.useCloseButton;
		}
		/**
		 * @private
		 */
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			if (lockPanel && child == dockContainer)
			{
				return child;
			}
			
			var retObj:DisplayObject = super.removeChild(child);
			if (numChildren == 0)
			{
				parent.removeChild(this);
			}
			return retObj;
		}
		/**
		 * @private
		 */
		override public function get explicitMinWidth():Number
		{
			var superExplicitMinWidth:Number = super.explicitMinWidth;
			if (!isNaN(superExplicitMinWidth))
			{
				return superExplicitMinWidth;
			}
			if (dockContainer!= null)
			{
				return dockContainer.explicitMinWidth + getStyle("paddingLeft") + getStyle("paddingRight") + getStyle("borderThicknessLeft") + getStyle("borderThicknessRight");
			}
			else
			{
				return getStyle("paddingLeft") + getStyle("paddingRight") + getStyle("borderThicknessLeft") + getStyle("borderThicknessRight");
			}
			
		}
		/**
		 * @private
		 */
		override public function get explicitMinHeight():Number
		{
			var superExplicitMinHeight:Number = super.explicitMinHeight;
			if (!isNaN(superExplicitMinHeight))
			{
				return superExplicitMinHeight;
			}
			if (dockContainer!= null)
			{
				return dockContainer.explicitMinHeight + getStyle("headerHeight") + getStyle("paddingTop")+ getStyle("paddingBottom") + getStyle("borderThicknessTop") + getStyle("borderThicknessBottom");
			}
			else
			{
				return getStyle("headerHeight") + getStyle("paddingTop")+ getStyle("paddingBottom") + getStyle("borderThicknessTop") + getStyle("borderThicknessBottom");
			}
		}

		protected function handleClose(e:Event):void
		{
			if (dockContainer != null)
			{
				dockContainer.closeChild();
			}
		}
	}
}
