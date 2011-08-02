package
{
	import flash.display.Sprite;
	
	public class MySprite extends Sprite
	{
		public function MySprite()
		{
			super();

//			graphics.lineStyle(3, 0x770000);
			graphics.beginFill(0xff0000);
			graphics.drawRect(0, 0, 100, 100);
			graphics.endFill();
			
		}
		
		public override function get width():Number
		{
			return super.width;
		}
	}
}