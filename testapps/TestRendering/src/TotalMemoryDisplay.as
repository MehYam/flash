package
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	public class TotalMemoryDisplay extends Sprite
	{
		private var memory:TextField = new TextField;
		private var fps:TextField = new TextField;

		private static function setupTextField(tf:TextField):void
		{
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.defaultTextFormat = new TextFormat("Arial", 20, 0xffffff);
		}
		public function TotalMemoryDisplay()
		{
			setupTextField(memory);
			addChild(memory);

			setupTextField(fps);
			fps.y = 25;
			addChild(fps);
			
			onEnterFrame(null);
		}
		public function activate(b:Boolean, stage:Stage):void
		{
			if (b) {
				stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			}
			else {
				stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		private var _lastUpdate:uint = 0;
		private var _frames:uint;
		private function onEnterFrame(evt:Event):void
		{
			++_frames;
			
			const now:uint = getTimer();
			if (now > (_lastUpdate + 1000))
			{
				memory.text = "System.totalMemory: " + (System.totalMemory / (1024*1024)) + "MB";
				fps.text = "fps: " + (_frames * 1000 / (now - _lastUpdate));
				
				_lastUpdate = now;
				_frames = 0;
			}
		}
	}
}
