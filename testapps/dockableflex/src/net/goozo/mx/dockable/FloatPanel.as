package net.goozo.mx.dockable
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.controls.Button;
	import mx.core.Container;
	import mx.styles.StyleProxy;
	
[IconFile("FloatPanel.png")]

	/**
	 *  FloatPanel is a draggable and resizable titled window class.
	 *  A FloatPanel instance lays above all the DockablePanel.
	 *  The parent of the FloatPanel is either a Canvas instance or
	 *  an Application instance.
	 *  The first DockableDevidedBox placed on the stage will search its
	 *  parents to find a Canvas instance or an Application instance. And all
	 *  the FloatPanel created later instances will use it as its parent.
	 */
	public class FloatPanel extends ClosablePanel
	{
		override public function get panelType():int
		{
			return DockManager.FLOATPANEL;
		}
		
		private var resizeButton:Button = null;
		
		private var _showResizeButton:Boolean = true;;
		
		private static var _resizeButtonStyleFilters:Object = 
		{
			"resizeButtonUpSkin" : "upSkin", 
			"resizeButtonOverSkin" : "overSkin", 
			"resizeButtonDownSkin" : "downSkin", 
			"resizeButtonDisabledSkin" : "disabledSkin", 
			"resizeButtonSkin" : "skin", 
			"repeatDelay" : "repeatDelay", 
			"repeatInterval" : "repeatInterval"
	    };
		
	    /**
		 *  @private
		 */
		protected function get resizeButtonStyleFilters():Object
		{
			return _resizeButtonStyleFilters;
		}
	
		/**
		 *  Show or hide the resize button
		 */
		public function get showResizeButton():Boolean
		{
			return _showResizeButton;
		}
		public function set showResizeButton(value:Boolean):void
		{
			_showResizeButton = value;
			resizeButton.visible = value;
		}
		
		
    	[Inspectable(category = "General", enumeration = "true, false", defaultValue = "true")]
		/**
		 *  @private
		 */
	    override public function set enabled(value:Boolean):void
	    {
	        super.enabled = value;
	        
	        if (resizeButton)
	        	resizeButton.enabled = value;
	    }
	    
		/**
		 *  Constructor
		 *  @param	fromChild If fromChild is not an IDockableContainer instance, 
		 *  a new DockableTabNavigator will be created, and put it as its first
		 *  tab child.
		 */
		public function FloatPanel(fromChild:Container = null)
		{
			super(fromChild);
		}
		
		/**
		 *  @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
	        
	        if (!resizeButton)
	        {
	            resizeButton = new Button();
	            resizeButton.styleName = new StyleProxy(this, resizeButtonStyleFilters);
	            
	            resizeButton.focusEnabled = false;

	            resizeButton.enabled = enabled;
	            resizeButton.visible = _showResizeButton;

	            rawChildren.addChild(resizeButton);
				resizeButton.owner = this;
	
				titleBar.addEventListener(MouseEvent.MOUSE_DOWN, handleStartDragTitle);
	 			resizeButton.addEventListener(MouseEvent.MOUSE_DOWN, handleStartResize);
	 						
				callLater(fixFloatSize);
	        }									
		}
		/**
		 *  @private
		 */
		override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutChrome(unscaledWidth, unscaledHeight);
			
			// The previewer in Flex builder can not get the getStyle properly, so ..
			if (_showResizeButton && resizeButton)
			{
				var resizeButtonWidth:Number = getStyle("resizeButtonWidth");
				var resizeButtonHeight:Number = getStyle("resizeButtonHeight");
				if (resizeButtonWidth > 0 && resizeButtonHeight > 0)
				{
					resizeButton.width = getStyle("resizeButtonWidth");
					resizeButton.height = getStyle("resizeButtonHeight");
				}
				else
				{
					resizeButton.width = 7;
					resizeButton.height = 7;
				}			
				resizeButton.move(unscaledWidth - resizeButton.width , unscaledHeight - resizeButton.height);
			}	
		}
		
		private function handleStartResize(e:MouseEvent):void
		{
			if (_showResizeButton)
			{
				stage.addEventListener(MouseEvent.MOUSE_UP, handleStopResize);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, handleResize);
			}
		}
		private function handleStopResize(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleStopResize);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleResize);
		}
		private function handleResize(e:MouseEvent):void
		{
			width = Math.max(mouseX + resizeButton.width/2, minWidth);
			height = Math.max(mouseY + resizeButton.height/2, minHeight);
		}
		
		private function handleStartDragTitle(e:MouseEvent):void
		{
			var bounds:Rectangle = new Rectangle(0, 0, parent.width, parent.height);
			bounds.x -= width-4;
			bounds.width += width-8;
			bounds.height -= 4;
			startDrag(false, bounds);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleStopDragTitle);
		}
		private function handleStopDragTitle(e:MouseEvent):void
		{
			stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleStopDragTitle);
		}

		private function fixFloatSize():void
		{
			if (initialized)
			{
				var tMinWidth:Number = minWidth;
				var tMinHeight:Number = minHeight;
				if (width < tMinWidth
				 && width < tMinWidth*2
				 && height < tMinHeight
				 && height < tMinHeight*2
				){
					width = width;
					height = height;
				}
				else
				{
					width = Math.max(parent.width/3, tMinWidth);
					height = Math.max(parent.height/3, tMinHeight);
				}
			}
			else
			{
				callLater(fixFloatSize);
			}
		}
	}
}
