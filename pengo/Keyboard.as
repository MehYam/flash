package
{
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	
	//
	// This thing manages keyboard input for us;  it requires a bit more than simply waiting for 
	// a cursor-key event, since they will overlap as the user moves around, and the "free"
	// functionality you get relying on repeated keydowns for a key held down depends on the
	// keyboard repeat delay and rate 
	public class Keyboard
	{
		public static const KEY_NONE:uint = 0;
		public static const KEY_SPACE:uint = 32;
		public static const KEY_LEFT:uint = 37;
		public static const KEY_UP:uint = 38;
		public static const KEY_RIGHT:uint = 39;
		public static const KEY_DOWN:uint = 40;

		public function Keyboard(target:EventDispatcher)
		{
			target.addEventListener(KeyboardEvent.KEY_DOWN, keyDown, false, 0, true);		
			target.addEventListener(KeyboardEvent.KEY_UP, keyUp, false, 0, true);		
		}

		private var _keyTable:Object = {};
		private var _cursorKey:uint = KEY_NONE;
		public function get cursorKey():uint
		{
			return _cursorKey;
		}
		public function get spaceKey():Boolean
		{
			return _keyTable[KEY_SPACE];
		}

		private function keyDown(event:KeyboardEvent):void
		{
			_keyTable[event.keyCode] = true;

			switch(event.keyCode) {
			case KEY_LEFT:
			case KEY_RIGHT:
			case KEY_UP:
			case KEY_DOWN:
				_cursorKey = event.keyCode;
				break;
			}
		}

		private function keyUp(event:KeyboardEvent):void
		{
			_keyTable[event.keyCode] = false;

			switch(event.keyCode) {
			case KEY_LEFT:
			case KEY_RIGHT:
			case KEY_UP:
			case KEY_DOWN:
				// another cursor key may already be down
				if (_keyTable[KEY_LEFT])
				{
					_cursorKey = KEY_LEFT;
				}
				else if (_keyTable[KEY_RIGHT])
				{
					_cursorKey = KEY_RIGHT;
				}
				else if (_keyTable[KEY_UP])
				{
					_cursorKey = KEY_UP;
				}
				else if (_keyTable[KEY_DOWN])
				{
					_cursorKey = KEY_DOWN;
				}
				else
				{
					_cursorKey = KEY_NONE;
				}
				break;		
			}	
		}
	}
}