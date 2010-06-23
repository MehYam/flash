package karnold.utils
{
	import flash.geom.Point;

	public class Physics
	{
		static private const DEGREES_FACTOR:Number = 180/Math.PI;
		static public function getDegreesRotation(deltaX:Number, deltaY:Number):Number
		{
			return Math.atan2(deltaX, -deltaY) * DEGREES_FACTOR;
		}
		static public function getRadiansRotation(deltaX:Number, deltaY:Number):Number
		{
			return Math.atan2(deltaX, -deltaY);
		}
		static private const SPEED_ALPHA:Number = 0.3;
		static public function speedDecay(speed:Number, decay:Number):Number
		{
			var retval:Number = speed * (1-decay);
			return (Math.abs(retval) < SPEED_ALPHA) ? 0 : retval;
		}
		static public function constrain(bounds:Bounds, point:Point, width:Number, height:Number, speedForBounce:Point = null):void
		{
			// contain world position
			if (point.x < bounds.left)
			{
				point.x = bounds.left;
				speedForBounce.x = -speedForBounce.x;
			}
			else
			{
				const maxHorz:Number = bounds.right - width;
				if (point.x > maxHorz)
				{
					point.x = maxHorz;
					speedForBounce.x = -speedForBounce.x;
				}
			}
			if (point.y < bounds.top)
			{
				point.y = bounds.top;
				speedForBounce.y = -speedForBounce.y;
			}
			else 
			{
				const maxVert:Number = bounds.bottom - height;
				if (point.y > maxVert)
				{
					point.y = maxVert;
					speedForBounce.y = -speedForBounce.y;
				}
			}
		}
		static public function constrainAbsoluteValue(value:Number, limit:Number):Number
		{
			if (value < (-limit))
			{
				return -limit;
			}
			if (value > limit)
			{
				return limit;
			}
			return value;
		}
	}
}