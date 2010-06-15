package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class RasterTextFieldTester extends Sprite
	{
		public function RasterTextFieldTester()
		{
// this generates the string of characters as trace output
//			var out:String = "";
//			var n:int = 0;
//			for (var i:int = 32; i < 128; ++i) {
//				out += String.fromCharCode(i);
//				if ((++n % 15) == 0)
//				{
//					trace(out);
//					out = "";
//				}
//			}
//			trace(out);

			var rtf:RasterTextField = new RasterTextField;
			rtf.x = 20;
			rtf.y = 20;
			rtf.integer = -3423423;
			addChild(rtf);
			
			rtf.suffix = " KB";

			var tf:TextField = new TextField;
			tf.x = 20;
			tf.y = 50;
			addChild(tf);

			const pre:int = getTimer();
			trace("pre: " + pre);
			
//			for (var i:int = 0; i < 500000; ++i)
//			{
////				tf.text = String(i) + " KB";
//				rtf.integer = i;
//
//				if ((i % 100000) == 0)
//				{
//					trace("s.tm: " + System.totalMemory);
//				}
//			}

			
			trace("post elapsed: " + (getTimer() - pre));

			var timer:Timer = new Timer(1000, 20);
			timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
//			timer.start();
		}
		
		private var _count:uint = 6341;
		private function onTimer(e:Event):void
		{
			RasterTextField(getChildAt(0)).integer = _count++;
		}
	}
}
