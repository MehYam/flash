// ActionScript file
package
{
	import flash.geom.Point;
	
	public class Utils
	{
		public static function randomInt(low:int, high:int):int
		{
			return Math.floor(Math.random() * (high - low) + low);
		}
		public static function create2DArray(n:uint, m:uint):Array
		{
			var retval:Array = []
			for (var i:uint = 0; i < n; ++i)
			{
				retval.push(new Array(m));
			}
			return retval;
		}
		
		public static function normalizeDirection(x:Number):Number
		{
			//KAI: profile this, for fun
			//return (x == 0) ? 0 : (Math.abs(x)/x);
			if (x != 0)
			{
				return (x > 0) ? 1 : -1;
			}
			return 0; 
		}
		
		//
		// Returns num rounded into the range min->max
		public static function restrictToRange(num:Number, min:Number, max:Number):Number
		{
			return Math.min(Math.max(num, min), max);
		}
		
		// order: stationary, left, up, right, down
		public static function directionToFourWayIndex(velocity:Point):uint
		{
			if (velocity)
			{
				if (velocity.x < 0)
				{
					return 1;
				}
				if (velocity.y < 0)
				{
					return 2;
				}
				if (velocity.x > 0)
				{
					return 3;
				}
				if (velocity.y > 0)
				{
					return 4;
				}
			}
			return 0;
		}
		public static function directionToAnimatorNode(xml:XML, velocity:Point, directions:Array):XML
		{
			return selectAnimatorNode(xml, directions[directionToFourWayIndex(velocity)]);
		}
		public static function selectAnimatorNode(xml:XML, attrName:String):XML
		{
			return xml.tileset.tile.(@name == attrName)[0];	
		}
		
	}
}// ActionScript file
