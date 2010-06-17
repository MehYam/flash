package karnold.utils
{
	import flash.geom.Point;

	public class Bounds
	{
		public var left:int;
		public var top:int;
		public var right:int;
		public var bottom:int;

		public function Bounds(left:int = 0, top:int = 0, right:int = 0, bottom:int = 0)
		{
			this.left = left;
			this.top = top;
			this.right = right;
			this.bottom = bottom;
		}
		public function toString():String
		{
//			return "(left=" + left + ", top=" + top + ", right=" + right + ", bottom=" + bottom + ")";
			return "(x " + left + "=>" + right + ", y " + top + "=>" + bottom + ")";
		}
		public function setBounds(rhs:Bounds):void
		{
			left = rhs.left;
			top = rhs.top;
			right = rhs.right;
			bottom = rhs.bottom;
		}
		public function get empty():Boolean
		{
			return !(right > left && bottom > top);
		}
		public function equals(rhs:Bounds):Boolean
		{
			return left == rhs.left && top == rhs.top && right == rhs.right && bottom == rhs.bottom;  
		}
		public function contains(x:uint, y:uint):Boolean
		{
			return x >= left && x <= right && y >= top && y <= bottom;
		}
		public function intersect(a:Bounds, b:Bounds):void
		{
			top = Math.max(a.top, b.top);
			bottom = Math.min(a.bottom, b.bottom);
			left = Math.max(a.left, b.left);
			right = Math.min(a.right, b.right);
		}
		public function union(a:Bounds, b:Bounds):void
		{
			top = Math.min(a.top, b.top);
			bottom = Math.max(a.bottom, b.bottom);
			left = Math.min(a.left, b.left);
			right = Math.max(a.right, b.right);
		}
		public function get middle():Point
		{
			return new Point((right - left) / 2, (bottom - top) / 2);
		}
	}
}