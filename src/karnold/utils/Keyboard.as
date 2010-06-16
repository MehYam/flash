package karnold.utils
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;

	public class Keyboard
	{
		public static const KEY_LEFT:uint = 37;
		public static const KEY_RIGHT:uint = 39;
		public static const KEY_UP:uint = 38;
		public static const KEY_DOWN:uint = 40;
		
		public var keys:Array = [];
		public function Keyboard(source:DisplayObject)
		{
			source.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			source.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
		}
		private function onKeyDown(e:KeyboardEvent):void
		{
			keys[e.keyCode] = true;
		}
		private function onKeyUp(e:KeyboardEvent):void
		{
			keys[e.keyCode] = false;
		}
	}
}