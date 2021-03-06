package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;

	public final class TestMovement extends Sprite
	{
		static private const CELL_SIZE:uint = 100;

		private var _map:Array2D = new Array2D(100, 200);
		private var _keyboard:Keyboard;
		private var _theRoyalWe:WorldObject;
		public function TestMovement()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			
			_keyboard = new Keyboard(stage);
			
			_theRoyalWe = new WorldObject(0xff0000, 20, 20);
			addChild(_theRoyalWe);

			initMap(_map, 0.2);
		}

		private static const SPEED:uint = 10;
		private var _worldPosition:Point = new Point;
		private function onEnterFrame(_unused:Event):void
		{
			if (_keyboard.keys[Keyboard.KEY_RIGHT])
			{
				_worldPosition.x += SPEED;
			}
			else if (_keyboard.keys[Keyboard.KEY_LEFT])
			{
				_worldPosition.x -= SPEED;
			}
			
			if (_keyboard.keys[Keyboard.KEY_DOWN])
			{
				_worldPosition.y += SPEED;
			}
			else if (_keyboard.keys[Keyboard.KEY_UP])
			{
				_worldPosition.y -= SPEED;
			}
			
			renderScene();
		}

		private var _lastWorldPosition:Point = new Point;
		private var _lastBounds:Bounds = new Bounds;

		// [kja] premature optimization - these are kept around to avoid allocating them every frame 
		private var _currentBounds:Bounds = new Bounds;
		//private var _intersection:Bounds = new Bounds;
		//private var _union:Bounds = new Bounds;
		private var _worldPositionCellOffset:Point = new Point;
		private function renderScene():void
		{
			_theRoyalWe.x = stage.stageWidth/2;
			_theRoyalWe.y = stage.stageHeight/2;

			// determine the before/after of the world scene bounds
			const stageRows:uint = stage.stageHeight/CELL_SIZE;
			const stageCols:uint = stage.stageWidth/CELL_SIZE;
			_currentBounds.left = _worldPosition.x/CELL_SIZE;
			_currentBounds.right =  _currentBounds.left + stageCols;
			
			_currentBounds.top = _worldPosition.y/CELL_SIZE;
			_currentBounds.bottom = _currentBounds.top + stageRows;

			_worldPositionCellOffset.x = _worldPosition.x%CELL_SIZE;
			_worldPositionCellOffset.y = _worldPosition.y%CELL_SIZE;

			// loop through the objects in current bounds, setting their position, and adding
			// them to the stage if they're not yet there
			var row:uint;
			var col:uint;
			for (row = Math.max(0, _currentBounds.top); row < _currentBounds.bottom; ++row)
			{
				for (col = Math.max(0, _currentBounds.left); col < _currentBounds.right; ++col)
				{
					var wo:WorldObject = WorldObject(_map.lookup(row, col));
					if (wo)
					{
						wo.x = (row - _currentBounds.left) * CELL_SIZE - _worldPositionCellOffset.x;
						wo.y = (col - _currentBounds.top) * CELL_SIZE - _worldPositionCellOffset.y;
						if (!wo.parent)
						{
							parent.addChild(wo);
trace("adding", row, col);							
						}
					}
				}
			} 
			// loop through the objects of the last bounds, removing them if they're offscreen
			if (!_currentBounds.equals(_lastBounds))
			{
				const left:uint = Math.max(0, _lastBounds.left); 
				for (row = Math.max(0, _lastBounds.top); row < _lastBounds.bottom; ++row)
				{
					for (col = left; col < _lastBounds.right; ++col)
					{
						var removee:WorldObject = WorldObject(_map.lookup(row, col));
						if (removee)
						{
							if (removee.parent && !_currentBounds.contains(row, col))
							{
							removee.parent.removeChild(removee);
	trace("removing", row, col);
							}
						}
					}
				} 
			}
			_lastBounds.setBounds(_currentBounds);
		}

		private static function initMap(map:Array2D, densityPct:Number):void
		{

map.put(new WorldObject(0xff00ff, 20, 20), 0, 0);
map.put(new WorldObject(0x00ff00, 20, 20), 1, 1);
map.put(new WorldObject(0x0000ff, 20, 20), 2, 2);
return;			
			const count:uint = densityPct * (map.rows * map.cols);

			const ROWS:uint = map.rows;
			const COLS:uint = map.cols;
			for (var i:uint = 0; i < count; ++i)
			{
				var loc:Location = findBlank(map, Math.random() * ROWS, Math.random() * COLS);
				if (loc)
				{
					// [kja] we're using DisplayObjects in our actual map - the map instead should just be data,
					// and we instead simply pool DisplayObjects, reusing them as necessary.
					var wo:WorldObject = new WorldObject(Math.random() * 0xffffff, 10 + (Math.random() * 10), 10 + (Math.random() * 10));
					map.put(wo, loc.row, loc.col);
				} 
			} 
		}
		
		private static function findBlank(map:Array2D, startRow:uint, startCol:uint):Location
		{
			const ROWS:uint = map.rows;
			const COLS:uint = map.cols;
			while (startCol < COLS)
			{
				if (!map.lookup(startRow, startCol))
				{
					return new Location(startRow, startCol);
				}
				if (++startRow >= ROWS)
				{
					startRow = 0;
					++startCol;
				}
			}
			return null;
		}
	}
}

	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;

final class Location
{
	public var row:int;
	public var col:int;
	public function Location(row:uint = 0, col:uint = 0)
	{
		setRowCol(row, col);
	}
	public function setRowCol(row:uint, col:uint):void
	{
		this.row = row;
		this.col = col;
	}
}

final class Bounds
{
	public var left:int;
	public var top:int;
	public var right:int;
	public var bottom:int;
	
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

final class Keyboard
{
	public static const KEY_LEFT:uint = 37;
	public static const KEY_RIGHT:uint = 39;
	public static const KEY_UP:uint = 38;
	public static const KEY_DOWN:uint = 40;

	public var keys:Array = [];
	public function Keyboard(source:DisplayObject)
	{
		source.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		source.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
	}
	private function onKeyDown(e:KeyboardEvent):void
	{
		keys[e.keyCode] = true;
	}
	private function onKeyUp(e:KeyboardEvent):void
	{
		keys[e.keyCode] = false;
	}
}