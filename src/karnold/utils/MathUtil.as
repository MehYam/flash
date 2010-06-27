package karnold.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class MathUtil
	{
		//
		// Like the Windows RGB macro
		static public function RGB(red:uint, green:uint, blue:uint):uint
		{
			return (red << 16) | (green << 8) | blue;
		}
		static public function random(min:Number, max:Number):Number
		{
			return min + (Math.random() * (max - min));
		}

		static private const RADIANS_TO_DEGREES:Number = 180/Math.PI;
		static private const DEGREES_TO_RADIANS:Number = Math.PI/180;
		static public function getDegreesRotation(deltaX:Number, deltaY:Number):Number
		{
			return Math.atan2(deltaX, -deltaY) * RADIANS_TO_DEGREES;
		}
		static public function getRadiansRotation(deltaX:Number, deltaY:Number):Number
		{
			return Math.atan2(deltaX, -deltaY);
		}
		static public function degreesToRadians(degrees:Number):Number
		{
			return degrees * DEGREES_TO_RADIANS;
		}
		static public function distanceBetweenPoints(a:Point, b:Point):Number
		{
			var x:Number = a.x - b.x;
			x *= x;
			
			var y:Number = a.y - b.y;
			y *= y;
			
			return Math.sqrt(x + y);
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
		static public function objectIsContained(dobj:DisplayObject, left:Number, top:Number, width:Number, height:Number):Boolean
		{
			return	dobj.x >= left &&
					dobj.y >= top &&
					((dobj.x + dobj.width) <= (left + width)) &&
					((dobj.y + dobj.height) <= (top + height));
		}
		static public function objectIntersects(dobj:DisplayObject, left:Number, top:Number, width:Number, height:Number):Boolean
		{
			return	dobj.x <= (left + width) &&
					dobj.y <= (top + height) &&
					left   <= (dobj.x + dobj.width) &&
					top    <= (dobj.y + dobj.height);
		}
	}
}