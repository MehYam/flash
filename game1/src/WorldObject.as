package
{
	import flash.display.Sprite;

	public final class WorldObject extends Sprite
	{
		public function WorldObject(color:uint, width:Number, height:Number)
		{
			super();
			
			this.graphics.lineStyle(1, 0);
			this.graphics.beginFill(color);
			this.graphics.drawEllipse(0, 0, width, height);
			this.graphics.endFill();
		}
	}
}