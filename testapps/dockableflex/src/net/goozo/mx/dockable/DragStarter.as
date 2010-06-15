package net.goozo.mx.dockable
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.managers.DragManager;


	internal class DragStarter extends EventDispatcher
	{
		private var target:DisplayObject;
		private var listener:Function;
		
		private var _distance:Number;

		
		private var listening:Boolean = false;;
		

		private var downEvent:MouseEvent;
		
		private var dragState:int = 0;//0:out 1:over 2:down
		
		public function DragStarter(target:DisplayObject, distance:Number = 5)
		{
				super(null);
				this.target = target;

				_distance = distance;
				

		}
		public function startListen(listener:Function):void
		{
			this.listener = listener;
			if (!listening)
			{
				listening = true;
				dragState = 0;
				
				target.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
				target.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
				target.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
				target.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			}
			
		}
		public function stopListen():void
		{
			listening = false;
				
			target.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			target.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			target.removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
			target.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			target.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);	
		}
		
		
		private function handleMouseDown(e:MouseEvent):void
		{
			if (e.target is Button && !Button(e.target).selected)
			{
				return;
			}
			dragState = 2;
			downEvent = e;
			target.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		private function handleMouseUp(e:MouseEvent):void
		{
			dragState = 1;
			target.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		private function handleMouseOver(e:MouseEvent):void
		{
			dragState = 1;
		}
		
		private function handleMouseMove(e:MouseEvent):void
		{
			if (Math.abs(e.localX-downEvent.localX) > _distance || Math.abs(e.localY-downEvent.localY) > _distance)
			{
				runListener(e);
			}
		}
		private function handleMouseOut(e:MouseEvent):void
		{
			if (dragState == 2)
			{
				runListener(e);
			}
			target.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			dragState = 0;
		}
		private function runListener(e:MouseEvent):void
		{
			if (DragManager.isDragging)
            {
            	return;
            }       
            target.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			dragState = 0;
			
			listener(downEvent);
		}
		
	}
}