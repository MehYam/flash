package karnold.utils
{
	public class Array2D
	{
		public function Array2D(width:uint = 0, height:uint = 0)
		{
			setSize(width, height);
		}

		//KAI: for the game, you could use a byte array instead, each char being a key or bitfield into some sort of data.
		private var _array:Array = [];
		private var _width:uint = 0;
		private var _height:uint = 0;
		public function setSize(width:uint, height:uint):void
		{
			_array.length = width * height;
			_width = width;
			_height = height;
		}
		
		public function put(obj:Object, x:uint, y:uint):void
		{
			_array[getIndex(x, y)] = obj;
		}
		
		public function lookup(x:uint, y:uint):Object
		{
			return (x < width && y < height) ? _array[getIndex(x, y)] : null;
		}
		
		public function get width():uint
		{
			return _width;
		}
		public function get height():uint
		{
			return _height;
		}

		private function getIndex(x:uint, y:uint):uint
		{
			return y * width + x;
		}
	}
}