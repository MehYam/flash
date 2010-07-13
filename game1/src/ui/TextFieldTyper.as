package ui
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	
	import karnold.utils.FrameTimer;

	public class TextFieldTyper extends EventDispatcher
	{
		private var _tf:TextField;
		private var _frameTimer:FrameTimer;
		private var _sounds:Boolean;
		public function TextFieldTyper(tf:TextField, sounds:Boolean)
		{
			_tf = tf;
			_frameTimer = new FrameTimer(onInterval);
			_sounds = sounds;
		}
		public function set sounds(b:Boolean):void
		{
			_sounds = b;
		}
		public function set textField(tf:TextField):void
		{
			_tf = tf;
		}
		private var _next:uint = 0;
		private var _text:Object;
		public function set text(t:String):void
		{
			_text = t;
			_next = 0;
		}
		public function set words(a:Array):void
		{
			_text = a;
			_next = 0;
		}
		public function get timer():FrameTimer
		{
			return _frameTimer;
		}
		
		private function onInterval():void
		{
			if (_next < _text.length && _text is String)
			{
				_tf.text = String(_text).substr(0, ++_next);

				if (_sounds)
				{
					AssetManager.instance.laserSound();
				}
			}
			else if (_next < _text.length && _text is Array)
			{
				_tf.text = (_text as Array).slice(0, ++_next).join(" ");
				
				if (_sounds)
				{
					AssetManager.instance.crashSound();
				}
			}
			else
			{
				_frameTimer.stop();
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
	}
}