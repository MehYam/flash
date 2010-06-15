package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class TotalMemoryDisplay extends Sprite
	{
		private var display:TextField = new TextField;
		private var timer:Timer = new Timer(1000);
		public function TotalMemoryDisplay()
		{
			display.selectable = false;
			display.autoSize = TextFieldAutoSize.LEFT;
			display.defaultTextFormat = new TextFormat("Arial", 20, 0xffffff);
			display.addEventListener(MouseEvent.CLICK, onTimer, false, 0, true);
			addChild(display);

			update();			
		}
		public function set autoUpdate(b:Boolean):void
		{
			if (b) {
				timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
				timer.start();
			}
			else {
				timer.stop();
			}
		}
		public function update():void
		{
			onTimer(null);
		}
		private function onTimer(unused:Event):void
		{
			display.text = "System.totalMemory: " + (System.totalMemory / (1024*1024)) + "MB";
		}
	}
}

//		private function formatCommaSeparated(num:uint):String
//		{
//			var str:String = String(num);
//			var out:String = "";
//			for (var i:uint = str.length; i >= 0; --i)
//			{
//				var place:uint = str.length - i - 1;
//				if ((place % 3) == 0)
//				{
//					out = "," + out;
//				}
//				out = str.charAt(
//			}
//			return out;
//		}
