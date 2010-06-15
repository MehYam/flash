package
{
	public class BallActor extends Actor
	{
		private var _lastSize:uint = 0;
		override public function onframe(frame:uint):void
		{
			const newSize:uint = (frame % 3) + 10;
			if (newSize != _lastSize) {
				_lastSize = newSize;

				graphics.clear();
				graphics.lineStyle(1, 0, 1.0);
				graphics.drawCircle(0, 0, newSize);
			}
		}
	}
}