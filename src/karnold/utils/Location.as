package karnold.utils
{
	public class Location
	{
		public var x:int;
		public var y:int;
		public function Location(x:uint = 0, y:uint = 0)
		{
			setLoc(x, y);
		}
		public function setLoc(x:uint, y:uint):void
		{
			this.x = x;
			this.y = y;
		}
	}
}