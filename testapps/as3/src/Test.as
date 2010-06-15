package
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;

	public class Test extends Sprite
	{
		public function Test(stage:Stage)
		{
			super();
			
			graphics.lineStyle(3, 0x00ff00);
			graphics.moveTo(0, 0);
			graphics.lineTo(100, 100);
			graphics.moveTo(100, 0);
			graphics.lineTo(0, 100);
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void
		{
			trace("enter frame");
		}
	}
}