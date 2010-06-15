package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class TestElement extends MovieClip
	{
		private var _child:Sprite = new Sprite;
		public function TestElement(width:Number, height:Number, color:uint)
		{
			this.graphics.lineStyle(0, 0xffffff);
			this.graphics.beginFill(color);
			this.graphics.drawRoundRect(0, 0, width, height, 10, 10);
			this.graphics.endFill();
			
			_child.graphics.lineStyle(0, 0);
			_child.graphics.beginFill(~color);
			_child.graphics.drawRect(0, 0, width/4, height/4);
			_child.graphics.endFill();
			_child.x = width * 0.375;
			_child.y = _child.x;

			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}
		
		private function onMouseOver(e:Object):void
		{
			this.addChild(_child);
		}
		private function onMouseOut(e:Object):void
		{
			this.removeChild(_child);
		}
		private function onMouseUp(e:MouseEvent):void
		{
			e.stopPropagation();
			e.stopImmediatePropagation();
		}
	}
}