package karnold.utils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class Input
	{
		public static const KEY_SPACE:uint = 32;
		public static const KEY_LEFT:uint = 37;
		public static const KEY_UP:uint = 38;
		public static const KEY_RIGHT:uint = 39;
		public static const KEY_DOWN:uint = 40;
		public static const KEY_TILDE:uint = 192;
		
		public static const MOUSE_BUTTON:uint = 666;
		
		private var _keyState:Array = [];
		private var _keyHistory:Array = [];
		private var _keyMappings:Dictionary = new Dictionary;

		public function Input(source:DisplayObject)
		{
			Utils.listen(source, KeyboardEvent.KEY_DOWN, onKeyDown);
			Utils.listen(source, KeyboardEvent.KEY_UP, onKeyUp);
			Utils.listen(source, MouseEvent.MOUSE_DOWN, onMouseDown);
			Utils.listen(source, MouseEvent.MOUSE_UP, onMouseUp);
			Utils.listen(source, Event.MOUSE_LEAVE, onMouseUp);
			
			addMapping('w', KEY_UP);
			addMapping('a', KEY_LEFT);
			addMapping('d', KEY_RIGHT);
			addMapping('s', KEY_DOWN);
		}
		private function addMapping(char:String, key:uint):void
		{
			_keyMappings[char.toLowerCase().charCodeAt(0)] = key;
			_keyMappings[char.toUpperCase().charCodeAt(0)] = key;
		}
		private function setKey(code:uint, val:Boolean):void
		{
			if (val)
			{
				if (!_keyState[code])
				{
					_keyHistory[code] = true;
				}
			}
			_keyState[code] = val;				
		}
		private function onKeyDown(e:KeyboardEvent):void
		{
			setKey(_keyMappings[e.keyCode] || e.keyCode, true); 
		}
		private function onKeyUp(e:KeyboardEvent):void
		{
			setKey(_keyMappings[e.keyCode] || e.keyCode, false);
		}
		
		private var _lastMouseDownCoords:Point = new Point;
		private function onMouseDown(e:MouseEvent):void
		{
			_lastMouseDownCoords.x = e.stageX;
			_lastMouseDownCoords.y = e.stageY;
			setKey(MOUSE_BUTTON, true);
		}
		public function get lastMouseDownCoords():Point
		{
			return _lastMouseDownCoords;
		}
		private function onMouseUp(e:Event):void
		{
			setKey(MOUSE_BUTTON, false);
		}
		
		public function isKeyDown(key:uint):Boolean
		{
			return _keyState[key];
		}
		// this is akin to the old asynchronous key polling in the windows SDK.  Useful for frame-based stuff,
		// prevents clients from having to queue things up for themselves
		public function checkKeyHistoryAndClear(key:uint):Boolean
		{
			const retval:Boolean = _keyHistory[key];
			_keyHistory[key] = false;
			return retval;
		}
	}
}