package de.aggro.components
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.containers.Panel;
	import mx.core.EdgeMetrics;
	import flash.geom.Point;
	import mx.skins.Border;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.DisplayObject;
	import mx.events.FlexEvent;
	import flash.events.Event;
	
	[Event(type="de.aggro.components.CollapsableTitleWindowEvent", name="close")]
	[Event(type="de.aggro.components.CollapsableTitleWindowEvent", name="expand")]
	[Event(type="de.aggro.components.CollapsableTitleWindowEvent", name="collapse")]
	[Event(type="de.aggro.components.CollapsableTitleWindowEvent", name="maximize")]
	[Event(type="de.aggro.components.CollapsableTitleWindowEvent", name="minimize")]
	[Event(type="de.aggro.components.CollapsableTitleWindowEvent", name="resize")]

	public class CollapsableTitleWindow extends Panel implements ICTWindow
	{	
		protected var closeButton:Sprite;		
		protected var maximizeButton:Sprite;
		protected var resizeButton:Sprite;		
		protected var collapseButton:Sprite;			
     	     	
     	private var boundsBeforeMaximize:Rectangle = new Rectangle();
     	private var boundsBeforeCollapse:Rectangle = new Rectangle();
     	
     	private var _isMaximized:Boolean;
     	private var _isCollapsed:Boolean;
     	
     	public function get isMaximized():Boolean{
     		return _isMaximized;
     	}
     	
     	public function get isCollapsed():Boolean{
     		return _isCollapsed;
     	}
     	
     	public var startCollapsed:Boolean = false;
     	public var startMaximized:Boolean = false;   
     	public var startMaximizedHeight:Boolean = false;
     	public var startMaximizedWidth:Boolean = false;
     	
     	public var allowClose:Boolean = true;
     	public var allowResize:Boolean = true;
     	public var allowMaximize:Boolean = true;
     	public var allowCollapse:Boolean = true;
     	
     	public var minimumWidth:Number = 0;
     	public var minimumHeight:Number = 0;
     	public var maximumWidth:Number = 0;
     	public var maximumHeight:Number = 0;
     	     	
     	private const buttonColor:Number = 0x000000;
     	private const buttonInactiveColor:Number = 0x666666;
		
		function CollapsableTitleWindow(){
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, initializeHandler);
		} 
		
		//Public functions
		public function maximize():void{
			maximizeHandler(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		public function minimize():void{
			minimizeHandler(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		public function collapse():void{
			collapseHandler(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		public function expand():void{
			expandHandler(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		//UIComponent overrides
			
		protected override function createChildren():void{
			super.createChildren();			
			
			//Create the Buttons
			maximizeButton = new Sprite();
			resizeButton = new Sprite();
			closeButton = new Sprite();
			collapseButton = new Sprite();
		
			if(allowMaximize==true){				
				titleBar.addChild(maximizeButton);
				maximizeButton.useHandCursor = true;
				maximizeButton.buttonMode = true;
				drawMaximizeButton(true, 0);
				maximizeButton.addEventListener(MouseEvent.MOUSE_DOWN, maximizeHandler);
				titleBar.doubleClickEnabled = true;
				titleBar.addEventListener(MouseEvent.DOUBLE_CLICK, maximizeHandler);
			}			
			
			if(allowResize==true){				
				titleBar.addChild(resizeButton);
				resizeButton.useHandCursor = true;
				resizeButton.buttonMode = true;
				drawResizeButton(true);
				resizeButton.addEventListener(MouseEvent.MOUSE_DOWN, resizeDownHandler);
			}				
			
			if(allowClose==true){
				titleBar.addChild(closeButton);
				closeButton.useHandCursor = true;
				closeButton.buttonMode = true;
				drawCloseButton(true);
				closeButton.addEventListener(MouseEvent.MOUSE_DOWN, closeHandler);
			}
			
			if(allowCollapse==true){				
				titleBar.addChild(collapseButton);
				collapseButton.useHandCursor = true;
				collapseButton.buttonMode = true;
				drawCollapseButton(true);
				collapseButton.addEventListener(MouseEvent.MOUSE_DOWN, collapseHandler);
			}			
				
                                    
            //Add handlers      
            titleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBarDownHandler);
           	
           	if(allowResize || allowMaximize){
           		//listen for parent resize
   	 			parent.addEventListener(Event.RESIZE, parentResizeHandler);            
           	}
           	
		}
			
		override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void
    	{
        	super.layoutChrome(unscaledWidth, unscaledHeight);
        	
        	var bm:EdgeMetrics = borderMetrics;
        	
        	var x:Number = bm.left;
       		var y:Number = bm.top;
       		
       		var headerHeight:Number = getHeaderHeight();
        	        	
            closeButton.x = unscaledWidth - x - bm.right - 10 - 15;
            closeButton.y = (headerHeight - 15) / 2;
            
            maximizeButton.x = closeButton.x - 15;
            maximizeButton.y = closeButton.y;
            
            collapseButton.x = maximizeButton.x - 15;
            collapseButton.y = maximizeButton.y;
                               
        	resizeButton.x = unscaledWidth - x - bm.right - 10;
        	resizeButton.y = unscaledHeight - resizeButton.height + 1;
        	
   	 	}
   	 	
   	 	//Event Handlers
   	 	
   	 	private function initializeHandler(event:FlexEvent):void{
   	 		//simulate the mousedown - don't want to copy the handler
   	 		if(startMaximized==true){   	 			
   	 			maximizeHandler(new MouseEvent(MouseEvent.MOUSE_DOWN));
   	 		}else if(startCollapsed==true){
   	 			collapseHandler(new MouseEvent(MouseEvent.MOUSE_DOWN));
   	 		}else{
   	 			
   	 			var initWidth:Number = width;
   	 			var initHeight:Number = height;
   	 			
   	 			if(startMaximizedHeight==true){
   	 				initHeight = parent.height;
   	 				y = 0;
   	 			}   	 				
   	 			
   	 			if(startMaximizedWidth==true){
   	 				initWidth = parent.width;
   	 				x = 0;
   	 			}   	 				
   	 			
   	 			applyConstraints(initWidth, initHeight);
   	 		}
   	 	}
   	 	
   	 	private function titleBarDownHandler(event:MouseEvent):void{
   	 		
   	 		parent.setChildIndex(this, parent.numChildren-1);
   	 		   	 		
   	 		var bounds:Rectangle = new Rectangle();
   	 		
   	 		bounds.x = 0;
   	 		bounds.y = 0;
   	 		bounds.width  = parent.width - width;
   	 		bounds.height = parent.height - height;
   	 		
   	 		this.startDrag(false, bounds);
   	 		
   	 		titleBar.addEventListener(MouseEvent.MOUSE_UP, titleBarUpHandler);   	 		
   	 		systemManager.addEventListener(MouseEvent.MOUSE_UP, titleBarUpHandler);
   	 		
   	 	}
   	 	   	 	
   	 	private function titleBarUpHandler(event:MouseEvent):void{
   	 		this.stopDrag();
   	 		
   	 		titleBar.removeEventListener(MouseEvent.MOUSE_UP, titleBarUpHandler);
   	 		systemManager.removeEventListener(MouseEvent.MOUSE_UP, titleBarUpHandler);
   	 	}
   	 	
   	 	private function resizeDownHandler(event:MouseEvent):void{
   	 		
   	 		event.stopImmediatePropagation();
   	 		
   	 		resizeButton.addEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
   	 		   	 		
   	 		systemManager.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
   	 		systemManager.addEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
   	 		
   	 	}
   	 	   	 	
   	 	private function resizeUpHandler(event:MouseEvent):void{
   	 		
   	 		event.stopImmediatePropagation();
   	 		
   	 		resizeButton.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
   	 		
   	 		systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
   	 		systemManager.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
   	 	}
   	 	
   	 	private function mouseMoveHandler(event:MouseEvent):void{
   	 		  	 		
   	 		var stagePoint:Point = new Point(event.stageX, event.stageY);
   	 		
   	 		var parentPoint:Point = parent.globalToLocal(stagePoint);
   	 		
   	 		var newWidth:Number = stagePoint.x - x;
   	 		var newHeight:Number = stagePoint.y - y;
   	 		
   	 		applyConstraints(newWidth, newHeight);
   	 		
   	 		dispatchEvent(new CollapsableTitleWindowEvent(CollapsableTitleWindowEvent.RESIZE, true, true));
   	 	}
   	 	
   	 	private function maximizeHandler(event:MouseEvent):void{
   	 		   	 		
   	 		event.stopImmediatePropagation();
   	 		   	 		
   	 		setParentsChildrenVisibility(false);
   	 		
   	 		if(isCollapsed == true){
   	 			setCollapseActive(false, 0);
   	 		}else{
   	 			setCollapseActive(false, 1);
   	 		}
   	 		
   	 		setMaximizeActive(true, 1);   	 		
   	 		setResizeActive(false);
   	 		setDragDropActive(false);
   	 		
   	 		boundsBeforeMaximize.x = x;
   	 		boundsBeforeMaximize.y = y;
   	 		boundsBeforeMaximize.width = width;
   	 		boundsBeforeMaximize.height = height;
   	 		
   	 		x = 0;
   	 		y = 0;
   	 		width = parent.width;
   	 		height = parent.height;  	 
   	 		
   	 		dispatchEvent(new CollapsableTitleWindowEvent(CollapsableTitleWindowEvent.MAXIMIZE, true, true));		
   	 	}
   	 	
   	 	private function minimizeHandler(event:MouseEvent):void{
   	 		
   	 		event.stopImmediatePropagation();
   	 		
   	 		setParentsChildrenVisibility(true);
   	 		
   	 		if(isCollapsed == true){
   	 			setCollapseActive(true, 0);
   	 			setResizeActive(true);
   	 		}else{
   	 			setCollapseActive(true, 1);
   	 			setResizeActive(false);
   	 		}
   	 		
   	 		setMaximizeActive(true, 0);   	    	 		
   	 		setDragDropActive(true);
   	 		   	 		
   	 		//Check the bounds, parent might have resized
   	 		if(boundsBeforeMaximize.width + boundsBeforeMaximize.x > parent.width)
   	 			boundsBeforeMaximize.width = parent.width - boundsBeforeMaximize.x;
   	 		
   	 		if(boundsBeforeMaximize.height + boundsBeforeMaximize.y > parent.height)
   	 			boundsBeforeMaximize.height = parent.height - boundsBeforeMaximize.y;
   	 		
   	 		
   	 		x = boundsBeforeMaximize.x;
   	 		y = boundsBeforeMaximize.y;
   	 		width = boundsBeforeMaximize.width;
   	 		height = boundsBeforeMaximize.height;  	
   	 		
   	 		dispatchEvent(new CollapsableTitleWindowEvent(CollapsableTitleWindowEvent.MINIMIZE, true, true));
   	 	}
   	 	
   	 	private function collapseHandler(event:MouseEvent):void{
   	 		
   	 		event.stopImmediatePropagation();
   	 		
   	 		setCollapseActive(false, 1);
   	 		setResizeActive(false);
   	 		setDragDropActive(false);
   	 		setMaximizeActive(false, 0);
   	 		
   	 		collapseButton.graphics.clear();
   	 		resizeButton.graphics.clear();
   	 		maximizeButton.graphics.clear();
   	 		
   	 		titleBar.addEventListener(MouseEvent.MOUSE_DOWN, expandHandler);
   	 		
   	 		boundsBeforeCollapse.height = height;
   	 		boundsBeforeCollapse.width = width;
   	 		boundsBeforeCollapse.x = x;
   	 		boundsBeforeCollapse.y = y;
   	 		   	 		
   	 		var bm:EdgeMetrics = viewMetrics;
   	 		height = bm.top; //+ bm.bottom;
   	 		
   	 		var minWidth:Number = titleTextField.textWidth 
   	 								+ collapseButton.width 
   	 								+ maximizeButton.width 
   	 								+ closeButton.width 
   	 								+ bm.left*2 + bm.right*2;
   	 								
   	 		width = minWidth;   	 		
   	 		
   	 		(parent as ICTWContainer).collapseChild(this);
   	 		
   	 		dispatchEvent(new CollapsableTitleWindowEvent(CollapsableTitleWindowEvent.COLLAPSE, true, true));
   	 	}
   	 	
   	 	private function expandHandler(event:MouseEvent):void{
   	 		
   	 		event.stopImmediatePropagation();
   	 		   	 		   	 		
   	 		setCollapseActive(true, 0);
   	 		setResizeActive(true);
   	 		setDragDropActive(true);
   	 		setMaximizeActive(true, 0);
   	 		
   	 		collapseButton.visible = true;
   	 		resizeButton.visible = true;
   	 		maximizeButton.visible = true;
   	 		
   	 		titleBar.removeEventListener(MouseEvent.MOUSE_DOWN, expandHandler);
   	 		
   	 		(parent as ICTWContainer).expandChild(this);
   	 		
   	 		//Check the bounds, stage might have resized
   	 		if(boundsBeforeCollapse.width + boundsBeforeCollapse.x > parent.width)
   	 			boundsBeforeCollapse.width = parent.width - boundsBeforeCollapse.x;
   	 		
   	 		if(boundsBeforeCollapse.height + boundsBeforeCollapse.y > parent.height)
   	 			boundsBeforeCollapse.height = parent.height - boundsBeforeCollapse.y;
   	 		
   	 		height = boundsBeforeCollapse.height;
   	 		width = boundsBeforeCollapse.width;
   	 		x = boundsBeforeCollapse.x;
   	 		y = boundsBeforeCollapse.y;
   	 		
   	 		dispatchEvent(new CollapsableTitleWindowEvent(CollapsableTitleWindowEvent.EXPAND, true, true));
   	 	}
   	 	
   	 	private function closeHandler(event:MouseEvent):void{
   	 		if(_isCollapsed)
   	 			(parent as ICTWContainer).expandChild(this);
   	 			
   	 		event.stopImmediatePropagation();
   	 		setParentsChildrenVisibility(true);
   	 		parent.removeChild(this);
   	 		
   	 		dispatchEvent(new CollapsableTitleWindowEvent(CollapsableTitleWindowEvent.CLOSE, true, true));
   	 	}
   	 	
   	 	private function parentResizeHandler(event:Event):void{
   	 		if(isMaximized == true){
   	 			x = 0;
	   	 		y = 0;
	   	 		width = parent.width;
	   	 		height = parent.height;
   	 		}else if(isCollapsed == false){
   	 			var newWidth:Number = width;
   	 			var newHeight:Number = height;
   	 			
   	 			if(width + x > parent.width)
   	 				newWidth = parent.width - x;
   	 			
   	 			if(height + y > parent.height)
   	 				newHeight = parent.height - y;
   	 			
   	 			applyConstraints(newWidth, newHeight);
   	 		}
   	 		
   	 		
   	 		dispatchEvent(new CollapsableTitleWindowEvent(CollapsableTitleWindowEvent.MAXIMIZE, true, true));
   	 	}
   	 	
   	 	//Disabling and enabling features
   	 	private function setDragDropActive(active:Boolean):void{
   	 		if(active == true){
   	 			titleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBarDownHandler);
   	 		}else{   	 			
   	 			titleBar.removeEventListener(MouseEvent.MOUSE_DOWN, titleBarDownHandler);
   	 		}
   	 	}   	 	
   	 	
   	 	private function setResizeActive(active:Boolean):void{
   	 		
   	 		drawResizeButton(active);
   	 		
   	 		if(active == true){
   	 			resizeButton.addEventListener(MouseEvent.MOUSE_DOWN, resizeDownHandler);
   	 		}else{   	 			
   	 			resizeButton.removeEventListener(MouseEvent.MOUSE_DOWN, resizeDownHandler);
   	 		}
   	 	}
   	 	
   	 	private function setMaximizeActive(active:Boolean, type:int):void{
   	 		drawMaximizeButton(active, type);
   	 		
   	 		if(type == 0){
   	 			
   	 			_isMaximized = false;
   	 			
   	 			titleBar.removeEventListener(MouseEvent.DOUBLE_CLICK, minimizeHandler);
	   	 		maximizeButton.removeEventListener(MouseEvent.MOUSE_DOWN, minimizeHandler);

   	 			if(active == true){   	 				
		           	titleBar.addEventListener(MouseEvent.DOUBLE_CLICK, maximizeHandler);
		           	maximizeButton.addEventListener(MouseEvent.MOUSE_DOWN, maximizeHandler);
	   	 		}else{   	 				
	   	 			titleBar.removeEventListener(MouseEvent.DOUBLE_CLICK, maximizeHandler);
	   	 			maximizeButton.removeEventListener(MouseEvent.MOUSE_DOWN, maximizeHandler);
	   	 		}
   	 		}else if(type == 1){
   	 			
   	 			_isMaximized = true;
   	 			titleBar.removeEventListener(MouseEvent.DOUBLE_CLICK, maximizeHandler);
	   	 		maximizeButton.removeEventListener(MouseEvent.MOUSE_DOWN, maximizeHandler);
	   	 		
   	 			if(active == true){  	 				
		           	titleBar.addEventListener(MouseEvent.DOUBLE_CLICK, minimizeHandler);
		           	maximizeButton.addEventListener(MouseEvent.MOUSE_DOWN, minimizeHandler);
	   	 		}else{
	   	 			titleBar.removeEventListener(MouseEvent.DOUBLE_CLICK, minimizeHandler);
	   	 			maximizeButton.removeEventListener(MouseEvent.MOUSE_DOWN, minimizeHandler);
	   	 		}
   	 		}
   	 		
   	 	}
   	 	
   	 	private function setCollapseActive(active:Boolean, type:int):void{
   	 		drawCollapseButton(active);
   	 		
   	 		if(type == 0){   	 			
   	 			_isCollapsed = false;
   	 			collapseButton.removeEventListener(MouseEvent.MOUSE_DOWN, expandHandler);
   	 			
   	 			if(active == true){
		           	collapseButton.addEventListener(MouseEvent.MOUSE_DOWN, collapseHandler);
	   	 		}else{	   	 			
	   	 			collapseButton.removeEventListener(MouseEvent.MOUSE_DOWN, collapseHandler);
	   	 		}
   	 		}else if(type == 1){   	 			
   	 			_isCollapsed = true;
   	 			collapseButton.removeEventListener(MouseEvent.MOUSE_DOWN, collapseHandler);
   	 			
   	 			if(active == true){
		           	collapseButton.addEventListener(MouseEvent.MOUSE_DOWN, expandHandler);
	   	 		}else{
	   	 			collapseButton.removeEventListener(MouseEvent.MOUSE_DOWN, expandHandler);
	   	 		}
   	 		}
   	 	}
   	 	
   	 	//Drawings
   	 	
   	 	private function drawCloseButton(active:Boolean):void{
   	 		
   	 		var col:Number;
   	 		
   	 		if(active == true){
   	 			col = buttonColor;
   	 		}else{
   	 			col = buttonInactiveColor;
   	 		}
   	 		
   	 		var g:Graphics = closeButton.graphics;
   	 		
   	 		g.clear();   	 		
   	 		g.lineStyle(1.5, col);
   	 		g.moveTo(2.5,2.5);
   	 		g.lineTo(7.5,7.5);
   	 		g.moveTo(7.5,2.5);
   	 		g.lineTo(2.5,7.5);
   	 		
   	 		g.lineStyle();
   	 		g.beginFill(0xFFFFFF, 0.01);
   	 		g.drawRect(0,0,10,10);
   	 	}
   	 	
   	 	private function drawResizeButton(active:Boolean):void{
   	 		
   	 		var col:Number;
   	 		
   	 		if(active == true){
   	 			col = buttonColor;
   	 		}else{
   	 			col = buttonInactiveColor;
   	 		}   	 			
   	 		
   	 		var g:Graphics = resizeButton.graphics;
   	 		
   	 		g.clear();   	 		
   	 		g.lineStyle(1, col);
   	 		g.moveTo(0,10);
   	 		g.lineTo(10,0);
   	 		g.moveTo(6,10);
   	 		g.lineTo(10,6);
   	 		g.moveTo(3,10);
   	 		g.lineTo(10,3);
   	 		
   	 		g.lineStyle();
   	 		g.beginFill(0xFFFFFF, 0.01);
   	 		g.drawRect(0,0,10,10);
   	 	}
		
		private function drawMaximizeButton(active:Boolean, type:int):void{
   	 		
   	 		var col:Number;
   	 		
   	 		if(active == true){
   	 			col = buttonColor;
   	 		}else{
   	 			col = buttonInactiveColor;
   	 		}
   	 		
   	 		var g:Graphics = maximizeButton.graphics;
   	 		
   	 		g.clear();   	 		
   	 		g.lineStyle(1, col);

			if(type == 0){
				g.drawRect(0,0,10,10);
				g.moveTo(0,1);
				g.lineTo(10,1);
			}else if(type == 1){
				g.drawRect(0,5,7,5);
				g.moveTo(0, 4);
				g.lineTo(8, 4);
				
				g.drawRect(3,2,7,5);
				g.moveTo(3, 1);
				g.lineTo(11, 1);
			}
			
			g.lineStyle();
			g.beginFill(0xFFFFFF, 0.01);
   	 		g.drawRect(0,0,10,10);

   	 	}
   	 	
   	 	private function drawCollapseButton(active:Boolean):void{
   	 		
   	 		var col:Number;
   	 		
   	 		if(active == true){
   	 			col = buttonColor;
   	 		}else{
   	 			col = buttonInactiveColor;
   	 		}
   	 		
   	 		var g:Graphics = collapseButton.graphics;
   	 		
   	 		g.clear();   	 		
   	 		g.lineStyle(1, col);
   	 		g.moveTo(0,10);
   	 		g.lineTo(10,10);
   	 		g.moveTo(0,9);
   	 		g.lineTo(10,9);
   	 		
   	 		g.lineStyle();
   	 		g.beginFill(0xFFFFFF, 0.01);
   	 		g.drawRect(0,0,10,10);
   	 	}
   	 	
   	 	//Other Methods
   	 	
   	 	private function applyConstraints(newWidth:Number, newHeight:Number):void{
   	 		
   	 		if(minimumWidth != 0 && newWidth < minimumWidth)
   	 			newWidth = minimumWidth;
   	 		
   	 		if(minimumHeight != 0 && newHeight < minimumHeight)
   	 			newHeight = minimumHeight;
   	 		
   	 		if(maximumWidth != 0 && newWidth > maximumWidth)
   	 			newWidth = maximumWidth;
   	 		
   	 		if(maximumHeight != 0 && newHeight > maximumHeight)
   	 			newHeight = maximumHeight;
   	 		   	 		   	 		
   	 		var bm:EdgeMetrics = viewMetrics;
   	 		
   	 		var minWidth:Number = titleTextField.textWidth 
   	 								+ collapseButton.width 
   	 								+ maximizeButton.width 
   	 								+ closeButton.width 
   	 								+ bm.left*2 + bm.right*2;
   	 		   	 		
   	 		if(newWidth + x > parent.width){
   	 			newWidth = parent.width - x;
   	 		}
   	 		
   	 		if(newHeight + y > parent.height){
   	 			newHeight = parent.height - y;
   	 		}	
   	 		
   	 		if(newWidth < minWidth)
   	 			newWidth = minWidth;
   	 		
   	 		if(newWidth < bm.left + bm.right)
   	 			newWidth = bm.left + bm.right;
   	 		  	 		
   	 		if(newHeight < bm.top + bm.bottom)
   	 			newHeight = bm.top + bm.bottom;
   	 		
   	 		width  = newWidth;
   	 		height = newHeight;
   	 	}
   	 	
   	 	private function setParentsChildrenVisibility(b:Boolean):void{
   	 		var n:int = parent.numChildren;
   	 		
   	 		for(var i:int = 0; i<n; i++){
   	 			var c:DisplayObject = parent.getChildAt(i);
   	 			if(c!=this)
   	 				c.visible = b;   	 			
   	 		}
   	 	}
	}
}