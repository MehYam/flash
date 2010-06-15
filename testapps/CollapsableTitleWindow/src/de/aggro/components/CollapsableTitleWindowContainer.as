package de.aggro.components
{
	import mx.containers.Canvas;
	import flash.display.DisplayObject;
	import mx.events.FlexEvent;
	import flash.events.Event;

	public class CollapsableTitleWindowContainer extends Canvas implements ICTWContainer
	{
		
		function CollapsableTitleWindowContainer(){
			addEventListener(Event.RESIZE, resizeHandler);
		}
		
		private function resizeHandler(event:Event):void{
			var childs:Array = getChildren();
			for each(var c:DisplayObject in childs){
				if((c as ICTWindow).isCollapsed)
					c.y = height - c.height;
			}
		}
		
		private var collapsedChilds:Number = 0;
		
		public function collapseChild(c:DisplayObject):void{
			c.y = height - c.height;
			c.x = getRightEdge(c);
			collapsedChilds++;
		}
		
		public function expandChild(current:DisplayObject):void{			
			var childs:Array = getChildren();
			for each(var c:DisplayObject in childs){
				if((c as ICTWindow).isCollapsed){
					if(c!=current){
						if(c.x > current.x){
							c.x -= current.width;
						}
					}			
				}
			}
			
			collapsedChilds--;
		}
		
		private function getRightEdge(current:DisplayObject):Number{
			
			if(collapsedChilds == 0){
				return 0;
			}
			
			var childs:Array = getChildren();
			var edge:Number = 0;
			for each(var c:DisplayObject in childs){
				if(c!=current){
					if((c as ICTWindow).isCollapsed){
						var childEdge:Number = c.width + c.x;
						if(childEdge>edge)
							edge = childEdge;
					}				
				}
			}
			return edge;
		}
	}
}