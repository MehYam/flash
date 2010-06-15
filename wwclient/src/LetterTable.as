package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[Event(name=LetterTableEvent.PATH_CHANGED, type="LetterTableEvent")]
	public class LetterTable extends EventDispatcher
	{
		private const _letters:Array = [];
		public function LetterTable()
		{
		}

		static private var _testData:String = null;//"QUNXMXJUOGJQJQNCWDGFZJLDQ";
		private var _rows:int = 0;
		private var _cols:int = 0;
		public function init(rows:int, cols:int):void
		{
			_letters.length = 0;
			if (_testData)
			{
				for (var s:int = 0; s < _testData.length; ++s)
				{
					_letters.push(LetterTile.create(_testData.charAt(s)));
				}
			}
			else
			{
				for (var i:int = 0; i < (rows*cols); ++i)
				{
					_letters.push(LetterTile.createRandom());
				}
			}
			_rows = rows;
			_cols = cols;
			path = null;
		}
		public function getLetter(row:int, col:int):String
		{
			return getLetterLinear(rowColToLinearIndex(row, col));
		}
		public function getLetterLinear(index:int):String
		{
			return LetterTile(_letters[index]).letter;
		}
		public function isMarked(index:int):Boolean
		{
			return LetterTile(_letters[index]).state == LetterTile.STATE_MARKED;
		}
		public function get containsCurrentPath():Boolean
		{
			return _pathExists;
		}
		private function rowColToLinearIndex(row:int, col:int):int
		{
			return row * _cols + col;
		}
		private var _path:String = null;
		public function set path(newPath:String):void
		{
			_path = newPath;

			updateLetterTileStates();
			
			dispatchEvent(new LetterTableEvent(LetterTableEvent.PATH_CHANGED));
		}
		
		private var _pathExists:Boolean = false;
		private function updateLetterTileStates():void
		{
			_pathExists = false;
			for (var i:int = 0; i < _letters.length; ++i)
			{
				LetterTile(_letters[i]).state = LetterTile.STATE_NORMAL;
			}

			if (_path)
			{
				var markedIndices:Array = []; 
				for (var row:int = 0; row < _rows; ++row)
				{
					for (var col:int = 0; col < _cols; ++col)
					{
						markedIndices.length = 0;
						checkPath(_path, 0, markedIndices, row, col);
					}
				}
			}
		}
		private function recordPath(markedIndices:Array):void
		{
			for (var index:Object in markedIndices)
			{
				if (markedIndices[index])
				{
					_pathExists = true;
					LetterTile(_letters[index]).state = LetterTile.STATE_MARKED;
				}
			}
		}
		
		private static const PATH_DIRECTIONS:Array =
		[
			{ row: -1, col: -1},
			{ row: -1, col:  0},
			{ row: -1, col:  1},
			{ row:  0, col:  1},
			{ row:  1, col:  1},
			{ row:  1, col:  0},
			{ row:  1, col: -1},
			{ row:  0, col: -1}
		];
		static private const Q:int = "Q".charCodeAt(0);
		static private const U:int = "U".charCodeAt(0);
		private function checkPath(strPath:String, pathPos:int, tilesMarked:Array, row:int, col:int):void
		{
			const index:int = rowColToLinearIndex(row, col);
			if (pathPos < strPath.length && row >= 0 && row < _rows && col >= 0 && col < _cols)
			{
				if (!tilesMarked[index])
				{
					const tile:LetterTile = _letters[index] as LetterTile;
					const thisPathCharCode:int = strPath.charCodeAt(pathPos); 
					if (tile && thisPathCharCode == tile.letter.charCodeAt(0))
					{
						tilesMarked[index] = true;
						if (pathPos == strPath.length - 1)
						{
							recordPath(tilesMarked);
						}
						else
						{
							for each (var direction:Object in PATH_DIRECTIONS)
							{
								checkPath(strPath, pathPos + 1, tilesMarked, row + direction.row, col + direction.col);
							}
							// special word racer logic for the optional U after Q - the board doesn't need a U
							if (thisPathCharCode == Q && (pathPos+1) < strPath.length && strPath.charCodeAt(pathPos+1) == U)
							{
								for each (var direction2:Object in PATH_DIRECTIONS)
								{
									checkPath(strPath, pathPos + 2, tilesMarked, row + direction2.row, col + direction2.col);
								}
								// weird, but if the user's typed only "QU", then the single Q counts as a match
								if (pathPos + 2 == strPath.length)
								{
									recordPath(tilesMarked);
								}
							}
						}
						tilesMarked[index] = false;
					}
				}
			}
		}
	}
}

class LetterTile
{
	public static const STATE_NORMAL:int = 0;
	public static const STATE_MARKED:int = 1;

	public var letter:String;
	public var state:int = STATE_NORMAL;
	
	private static const A:int = "A".charCodeAt();
	public static function createRandom():LetterTile
	{
		var retval:LetterTile = new LetterTile;
		retval.letter = String.fromCharCode(A + Math.random()*26);
		return retval;
	}
	public static function create(letter:String):LetterTile
	{
		var retval:LetterTile = new LetterTile;
		retval.letter = letter;
		return retval;
	}
};


/*
private function checkPath(strPath:String, pathIndex:int, tilesMarked:Array, row:int, col:int):Boolean
{
const index:int = rowColToLinearIndex(row, col);
if (pathIndex < strPath.length && row >= 0 && row < _rows && col >= 0 && col < _cols)
{
if (!tilesMarked[index])
{
const tile:LetterTile = _letters[index] as LetterTile;
if (tile && strPath.charCodeAt(pathIndex) == tile.letter.charCodeAt(0))
{
//KAI: problem on next line - multiple valid paths that overlap will cut each other off,
// because there's no indication which path is using the marked letter.
//
// the basic problem is that we can't follow multiple paths simultanenously with a simple grid of marked tiles;
// the alternative is to return the instant we've found a complete match, returning the state of the iteration
// along with it.  The caller is then obliged to restart the iteration where it left off.

tilesMarked[index] = true;
if (pathIndex == strPath.length - 1)
{
return true;
}
var retval:Boolean = false;
for each (var direction:Object in PATH_DIRECTIONS)
{
if (checkPath(strPath, pathIndex + 1, tilesMarked, row + direction.row, col + direction.col))
{
retval = true;
}
}
if (!retval)
{
tilesMarked[index] = false;
}
return retval;
}
}
}
return false;
}
*/