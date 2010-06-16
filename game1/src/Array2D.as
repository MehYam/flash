package
{
	//KAI: consider moving to karnold path
	public class Array2D
	{
		public function Array2D(rows:uint = 0, cols:uint = 0)
		{
			setSize(rows, cols);
		}

		//KAI: for the game, you could use a byte array instead, each char being a key or bitfield into some sort of data.
		private var _array:Array = [];
		private var _rows:uint = 0;
		private var _cols:uint = 0;
		public function setSize(rows:uint, cols:uint):void
		{
			_array.length = rows * cols;
			_rows = rows;
			_cols = cols;
		}
		
		public function put(obj:Object, row:uint, col:uint):void
		{
			_array[getIndex(row, col)] = obj;
		}
		
		public function lookup(row:uint, col:uint):Object
		{
			return (row < _rows && col < _cols) ? _array[getIndex(row, col)] : null;
		}
		
		public function get rows():uint
		{
			return _rows;
		}
		public function get cols():uint
		{
			return _cols;
		}

		private function getIndex(row:uint, col:uint):uint
		{
			return row * _cols + col;
		}
	}
}