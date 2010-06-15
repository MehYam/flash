package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class testEvent extends Sprite
	{
		private var _sc:SomeClass = null;
		public function testEvent()
		{
			_sc = new SomeClass(this);
			
			_sc.addEventListener(SomeEvent.EVENT1, event1, false, 0, true);
			_sc.addEventListener(SomeEvent.EVENT2, event2, false, 0, true);
			
			stage.addEventListener(MouseEvent.CLICK, click, false, 0, true);
		}
		
		private function event1(e:SomeEvent):void
		{
			trace("testEvent received event1");
		}
		
		private function event2(e:SomeEvent):void
		{
			trace("testEvent received event2");	
		}
		
		private function click(e:MouseEvent):void
		{
			trace("testEvent received click");
			
			dispatchEvent(new SomeEvent(int(e.localX % 2) ? SomeEvent.EVENT1 : SomeEvent.EVENT2));
		}
	}
}
