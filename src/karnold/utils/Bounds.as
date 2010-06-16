package karnold.utils
{
	public class Bounds
	{
		public var left:int;
		public var top:int;
		public var right:int;
		public var bottom:int;

		public function toString():String
		{
//			return "(left=" + left + ", top=" + top + ", right=" + right + ", bottom=" + bottom + ")";
			return "(" + left + ", " + top + ", " + right + ", " + bottom + ")";
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
	}
}