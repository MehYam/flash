package
{
	public class TestActor extends Actor
	{
		private var _lastSize:uint = 0;
		override public function onframe(frame:uint):void
		{
			const newSize:uint = (frame % 3) + 10;
			if (newSize != _lastSize) {
				_lastSize = newSize;

				graphics.clear();
				graphics.lineStyle(1, 0x000000, 1.0);
				graphics.drawRoundRect(0, 0, newSize, newSize, newSize, newSize);
			}
		}
	}
}