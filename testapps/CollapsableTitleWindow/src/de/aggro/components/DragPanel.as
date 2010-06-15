package de.aggro.components
{
	import mx.containers.Canvas;
    import mx.core.UIComponent;
    import mx.core.SpriteAsset;
    import mx.events.FlexEvent;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.ColorTransform;
    import flash.ui.Mouse;

	[Event(name="interactiveResize", type="flash.events.Event")]
    public class DragPanel extends Canvas
    {	
    	
    	
    	
        // Add the creationCOmplete event handler.
        public function DragPanel()
        {
            super();
            addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
            
            useHandCursor = true;
            buttonMode = true;
            
        }
        
        private function creationCompleteHandler(event:Event):void
        {
            // Add the resizing event handler.    
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);            
        }
        
        private var resizeRightBottom:Sprite;
        private var resizeLeftUpper:Sprite;
        
        private var rbContainer:UIComponent;
        private var luContainer:UIComponent;
        
        protected override function createChildren():void{
        	super.createChildren();
        	
        	rbContainer = new UIComponent();
	       	rbContainer.setStyle("right", 7);
	       	rbContainer.setStyle("bottom", 7);
	       	
        	resizeRightBottom = new Sprite();        	
        	addChild(rbContainer);
        	rbContainer.addChild(resizeRightBottom);
        	
        	luContainer = new UIComponent();
        	luContainer.setStyle("left", 0);
	       	luContainer.setStyle("top", 0);
	       	
        	resizeLeftUpper = new Sprite();
        	addChild(luContainer);
        	luContainer.addChild(resizeLeftUpper); 
        	
        	luContainer.addEventListener(MouseEvent.MOUSE_OVER, showFocus);
        	rbContainer.addEventListener(MouseEvent.MOUSE_OVER, showFocus);
        	
        	luContainer.addEventListener(MouseEvent.MOUSE_OUT, hideFocus);
        	rbContainer.addEventListener(MouseEvent.MOUSE_OUT, hideFocus);  
        	
        	luContainer.addEventListener(MouseEvent.MOUSE_DOWN, initResize);
        	rbContainer.addEventListener(MouseEvent.MOUSE_DOWN, initResize);
        	     	
        }
              
        protected override function childrenCreated():void{
        	super.childrenCreated();        	
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
        	
        	super.updateDisplayList(unscaledWidth, unscaledHeight);
        	
        	resizeRightBottom.graphics.clear();
        	resizeRightBottom.graphics.beginFill(0x0, 0.01);
        	resizeRightBottom.graphics.drawRect(0,0,7,7);
        	resizeRightBottom.graphics.endFill();
        	resizeRightBottom.graphics.lineStyle(1);
        	resizeRightBottom.graphics.moveTo(0,7);
        	resizeRightBottom.graphics.lineTo(7,0);
        	resizeRightBottom.graphics.moveTo(3,7);
        	resizeRightBottom.graphics.lineTo(7,3);
        	resizeRightBottom.graphics.moveTo(6,7);
        	resizeRightBottom.graphics.lineTo(7,6);     
        	
        	resizeLeftUpper.graphics.clear();
        	resizeLeftUpper.graphics.beginFill(0x0, 0.01);
        	resizeLeftUpper.graphics.drawRect(0,0,7,7);
        	resizeLeftUpper.graphics.endFill();
        	resizeLeftUpper.graphics.lineStyle(1);
        	resizeLeftUpper.graphics.moveTo(0,1);
        	resizeLeftUpper.graphics.lineTo(1,0);
        	resizeLeftUpper.graphics.moveTo(0,4);
        	resizeLeftUpper.graphics.lineTo(4,0);
        	resizeLeftUpper.graphics.moveTo(7,0);
        	resizeLeftUpper.graphics.lineTo(0,7);   
   	
        }
        
         private function initResize(e:MouseEvent):void{
        	        	       	
        	e.stopPropagation();
        	origWidth = width;
            origHeight = height;
            origX = x;
            origY = y;
            xOff = parent.mouseX;
            yOff = parent.mouseY;
            
            if(e.currentTarget == luContainer){
            	parent.addEventListener(MouseEvent.MOUSE_MOVE, resizePanel2);
	            parent.addEventListener(MouseEvent.MOUSE_UP, stopResizePanel2);
            }else if(e.currentTarget == rbContainer){
            	parent.addEventListener(MouseEvent.MOUSE_MOVE, resizePanel);
	            parent.addEventListener(MouseEvent.MOUSE_UP, stopResizePanel);
            }
            
        }
                
        private function showFocus(e:MouseEvent):void{
        	var c:UIComponent = e.currentTarget as UIComponent;
        	c.transform.colorTransform = new ColorTransform(1,1,1,1,255);
        }
        
        private function hideFocus(e:MouseEvent):void{
        	var c:UIComponent = e.currentTarget as UIComponent;
        	c.transform.colorTransform = new ColorTransform();
        }
        
        // Define static constant for event type.
        //public static const RESIZE_CLICK:String = "resizeClick";

        // Resize panel event handler.
        private var origWidth:Number;
        private var origHeight:Number;
        private var origX:Number;
        private var origY:Number;
        private var xOff:Number;
        private var yOff:Number;
        
        public  function mouseDownHandler(event:MouseEvent):void
        {
        	event.stopPropagation();
        	var rect:Rectangle = parent.getRect(parent);
        	rect.width -= width;
        	rect.height -= height;
        	startDrag(false, rect);
        	parent.addEventListener(MouseEvent.MOUSE_MOVE, dragPanel);
        	parent.addEventListener(MouseEvent.MOUSE_UP, stopDragPanel); 
        	       
        }
        
        private function resizePanel(event:MouseEvent):void {            
            width = origWidth + (parent.mouseX - xOff);            
            height = origHeight + (parent.mouseY - yOff);
            dispatchEvent(new Event("interactiveResize",true,true));
        }
        
        private function stopResizePanel(event:MouseEvent):void {
            parent.removeEventListener(MouseEvent.MOUSE_MOVE, resizePanel);
            hideFocus(event);
        }
        
        private function resizePanel2(event:MouseEvent):void {            
            var oldX:Number = x;
            var oldY:Number = y;
            
            x = origX + (parent.mouseX - xOff);  
            y = origY + (parent.mouseY - yOff);  
            
            width = origWidth - (x - origX);
            height = origHeight - (y - origY);
            
            dispatchEvent(new Event("interactiveResize",true,true));
        }
        
        private function stopResizePanel2(event:MouseEvent):void {
            parent.removeEventListener(MouseEvent.MOUSE_MOVE, resizePanel2);
            hideFocus(event);            
        }
        
        private function dragPanel(event:MouseEvent):void {
            dispatchEvent(new Event("interactiveResize",true,true));           
        }        
        
        private function stopDragPanel(event:MouseEvent):void {
            stopDrag();
            dispatchEvent(new Event("interactiveResize",true,true));
        }        
    }
}