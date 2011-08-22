package ui
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	
	import karnold.utils.FrameTimer;

	public class TextFieldTyper extends EventDispatcher
	{
		private var _tf:*;
		private var _frameTimer:FrameTimer;
		private var _sounds:Boolean;
		public function TextFieldTyper(textField:*, sounds:Boolean)  //KAI: should use an adapter class instead?
		{
			_tf = textField;
			_frameTimer = new FrameTimer(onInterval);
			_sounds = sounds;
		}
		private var _postDelay:uint;
		public function set postDelay(ms:uint):void
		{
			_postDelay = ms;
		}
		public function set sounds(b:Boolean):void
		{
			_sounds = b;
		}
		public function set textField(textField:*):void
		{
			_tf = textField;
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
		private var _postDelayTimer:FrameTimer = new FrameTimer(onDone);
		private function onInterval():void
		{
			if (_next < _text.length) 
			{
				if (_text is String)
				{
					_tf.text = String(_text).substr(0, ++_next);
	
					if (_sounds)
					{
						AssetManager.instance.laser2Sound();
					}
				}
				else
				{
					_tf.text = (_text as Array).slice(0, ++_next).join(" ");
					
					if (_sounds)
					{
						AssetManager.instance.explosionSoundIndex(0);
					}
				}
			}
			else
			{
				_frameTimer.stop();

				if (_postDelay)
				{
					_postDelayTimer.start(_postDelay, 1);
				}
				else
				{
					onDone();
				}
			}
		}
		public function skip():void
		{
			// force the final interval
			_next = _text.length - 1;
			onInterval();
			
			_frameTimer.stop();
			_postDelayTimer.stop();
			
			onDone();
		}
		private function onDone():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}