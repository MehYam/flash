package behaviors
{
	public class AmmoFireSource
	{
		public var ammoType:AmmoType;
		public var offsetX:Number;
		public var offsetY:Number;
		public var angle:Number;
		
		public function AmmoFireSource(type:AmmoType, x:Number, y:Number, angle:Number = 0)
		{
			ammoType = type;
			offsetX = x;
			offsetY = y;
			angle = angle;
		}
	}
}