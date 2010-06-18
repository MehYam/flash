package
{
	import flash.display.Sprite;

	public final class WorldObject extends Sprite
	{
		public function WorldObject()
		{
			super();
			mouseEnabled = false;
		}

		public static function createSpiro(color:uint, width:Number, height:Number):WorldObject
		{
			var wo:WorldObject = new WorldObject;
			
			wo.graphics.lineStyle(1, 0);
			wo.graphics.beginFill(color);
			wo.graphics.drawEllipse(width/4, 0, width/2, height);
			wo.graphics.drawEllipse(0, height/4, width, height/2);
			wo.graphics.endFill();
			
			drawOrigin(wo);
			return wo;
		}
		
		public static function createCircle(color:uint, width:Number, height:Number):WorldObject
		{
			var wo:WorldObject = new WorldObject;
			
			wo.graphics.lineStyle(1, 0);
			wo.graphics.beginFill(color);
			wo.graphics.drawEllipse(0, 0, width, height);
			wo.graphics.endFill();
			
			drawOrigin(wo);
			return wo;
		}
		
		public static function createSquare(color:uint, size:Number):WorldObject
		{
			var wo:WorldObject = new WorldObject;
			
			wo.graphics.lineStyle(1, color);
			wo.graphics.drawRect(0, 0, size, size);
			
			drawOrigin(wo);
			return wo;
		}
		
		private static function drawOrigin(obj:Sprite):void
		{
			obj.graphics.lineStyle(1, 0x777777, 0.5);
			obj.graphics.moveTo(0, 0);
			obj.graphics.lineTo(5, 0);
			obj.graphics.moveTo(0, 0);
			obj.graphics.lineTo(0, 5);
		}
	}
}