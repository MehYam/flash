package
{
	import flash.display.Sprite;
	import flash.system.System;

	public class SampleFrameTimerConsumer extends Sprite
	{
		private var _frameTimerHardReference:FrameTimer = new FrameTimer(onCallback);
		public function SampleFrameTimerConsumer()
		{
			super();
			
			this.graphics.lineStyle(4, 0xff00ff);
			this.graphics.drawRect(0, 0, 50, 50);
			
			_frameTimerHardReference.start(100);
		}
		
		private function onCallback():void
		{
			trace('unhooking display object, timer events should stop soon');
			
			if (parent)
			{
				parent.removeChild(this);
			}
			System.gc();
		}
	}
}