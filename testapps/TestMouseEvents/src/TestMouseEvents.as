package {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class TestMouseEvents extends Sprite
	{
		public function TestMouseEvents()
		{
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;

			test();
//			addChild(new SecondLayer(this.stage.stageWidth, this.stage.stageHeight));

			// strange rule number one - the code below won't fire a click event, although it will fire if you do this from SecondLayer.

//			this.graphics.lineStyle(0, 0xffffff);
//			this.graphics.beginFill(0xff00ff);
//			this.graphics.drawRect(0, 0, 100, 100);
//			this.graphics.endFill();
//
		}
		private function onMouseEvent(e:Event):void
		{
			trace(e.type, e);
		}
		
		private function addListeners(target:DisplayObject):void
		{
			target.addEventListener(MouseEvent.CLICK, onMouseEvent, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_OVER, onMouseEvent, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_OUT, onMouseEvent, false, 0, true);
		}
		private function test():void
		{
			var p:Sprite = new Sprite();
			p.graphics.lineStyle(1, 0x00ff00);
			p.graphics.drawRect(0, 0, 100, 100);
			p.x = 10;
			p.y = 10;

			var t:TestElement = new TestElement(40, 40, 0xff0000);
			t.x = 90;
			t.y = 90;
//			t.mouseEnabled = false;

			p.addChild(t);

			t = new TestElement(40, 40, 0x0000ff);
			t.x = 90;
			t.y = 20;
			p.addChild(t);
			p.hitArea = t; 
//			p.mouseEnabled = false;
//			p.mouseChildren = false;
			
			addListeners(p);
			addChild(p);
		}
	}
}
