package
{
	import flash.display.Sprite;
	
	public class SomeShape extends Sprite
	{
		public function SomeShape()
		{
			super();
			
			graphics.beginFill(0xff00ff, 0.5);
			graphics.lineStyle(3, 0x00ff00, 0.5);
			graphics.drawEllipse(50, 0, 100, 200);
			graphics.drawEllipse(0, 50, 200, 100);
			graphics.endFill();
		}
	}
}