package net.goozo.mx.dockable
{
	import flash.display.DisplayObject;
	
	import mx.containers.TabNavigator;
	import mx.core.Container;
	import mx.styles.StyleProxy;


	/**
	 *  ClosableTabNavigator is the base class of DockableTabNavigator
	 */
	public class ClosableTabNavigator extends TabNavigator
	{
		/**
		 *  If autoRemove is true, it will be removed when
		 *  all of its children have been removed.
		 */
		public var autoRemove:Boolean = true;
		
		/**
		 *  Constructor
		 */
		public function ClosableTabNavigator()
		{
			super();
		}
		/**
		 *  @private
		 */
	    override public function set selectedIndex(value:int):void
	    {
	    	super.selectedIndex = value;
	    	
	    	var childChangeEvent:ChildChangeEvent = new ChildChangeEvent(ChildChangeEvent.CHILD_CHANGE);
	    	if (value >= 0)
	    	{
		    	var newChild:Container = Container(getChildAt(value));	    	    	
		    	childChangeEvent.newTitle = newChild.label;
		    	if (newChild is IDockableTabChild)
		    	{
		    		childChangeEvent.useCloseButton = IDockableTabChild(newChild).closeTabEnabled;
		    	}					    		
	    	}
	    	dispatchEvent(childChangeEvent);
	    }

		/**
		 *  If autoRemove is true, the ClosableTabNavigator itself will
		 *  be removed after its last child has been removed.
		 */
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			if (child == selectedChild)
			{
				if (selectedIndex != numChildren-1)
				{
					var childChangeEvent:ChildChangeEvent = new ChildChangeEvent(ChildChangeEvent.CHILD_CHANGE);
					var newChild:Container = Container(getChildAt(selectedIndex+1));
					childChangeEvent.newTitle = newChild.label;
					if (newChild is IDockableTabChild)
		    		{
		    			childChangeEvent.useCloseButton = IDockableTabChild(newChild).closeTabEnabled;
		    		}
		    		dispatchEvent(childChangeEvent);
				}		
			}
			
			var retObj:DisplayObject = super.removeChild(child);
			if (numChildren == 0)
			{
				if (autoRemove && parent!= null)
				{
					parent.removeChild(this);
				}
				else
				{
					dispatchEvent(new ChildChangeEvent(ChildChangeEvent.CHILD_CHANGE));
				}
			}
			return retObj;
		}

		/**
		 *  Try closing the selected tab child.
		 *  @see IDockableTabChild#closeTab
		 */
		public function closeChild():void
		{
			if (selectedChild is IDockableTabChild
			 && IDockableTabChild(selectedChild).closeTabEnabled
			){
			 	if (IDockableTabChild(selectedChild).closeTab())
			 	{
			 		removeChild(selectedChild);
			 	}
			 }
		}
	}

}