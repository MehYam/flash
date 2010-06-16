package 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	
	import karnold.utils.Bounds;
	import karnold.utils.Keyboard;
	import karnold.utils.Utils;

	public final class game extends Sprite
	{
		static private const CELL_SIZE:uint = 50;

		private var _map:Array2D = new Array2D(20, 20);
		private var _keyboard:Keyboard;
		private var _player:WorldObject;
		public function game()
		{
			stage.align = StageAlign.TOP_LEFT;
//			stage.scaleMode = StageScaleMode.NO_SCALE;

			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			stage.focus = stage;

			_keyboard = new Keyboard(stage);
			
			_player = WorldObject.createCircle(0xff0000, 20, 20);
			addChild(_player);

			initMap(_map, 0.2);
			trace("stage", stage.stageWidth, stage.stageHeight);
			
			graphics.lineStyle(0, 0xff0000);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		}

		private static const SPEED:uint = 5;
		private var _worldPosition:Point = new Point(0, 0);
		private var _lastWorldPosition:Point = new Point(-1, -1);
		private function onEnterFrame(_unused:Event):void
		{
//			trace("stage", stage.stageWidth, stage.stageHeight);
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

			if (!_lastWorldPosition.equals(_worldPosition))
			{
				renderMap();
				
				Utils.setPoint(_lastWorldPosition, _worldPosition);
			}
		}

		private var _lastBounds:Bounds = new Bounds;

		// [kja] premature optimization - these are kept around to avoid allocating them every frame 
		private var _currentBounds:Bounds = new Bounds;
		//private var _intersection:Bounds = new Bounds;
		//private var _union:Bounds = new Bounds;
		private var _worldPositionCellOffset:Point = new Point;
		private function renderMap():void
		{
			_player.x = stage.stageWidth/2;
			_player.y = stage.stageHeight/2;

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
			for (row = Math.max(0, _currentBounds.top); row <= _currentBounds.bottom; ++row)
			{
				for (col = Math.max(0, _currentBounds.left); col <= _currentBounds.right; ++col)
				{
					var wo:WorldObject = WorldObject(_map.lookup(row, col));
					if (wo)
					{
						wo.x = (col - _currentBounds.left) * CELL_SIZE - _worldPositionCellOffset.x;
						wo.y = (row - _currentBounds.top) * CELL_SIZE - _worldPositionCellOffset.y;
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
trace("bounds change", _lastBounds, "to", _currentBounds);
				const left:uint = Math.max(0, _lastBounds.left); 
				for (row = Math.max(0, _lastBounds.top); row <= _lastBounds.bottom; ++row)
				{
					for (col = left; col <= _lastBounds.right; ++col)
					{
						var removee:DisplayObject = DisplayObject(_map.lookup(row, col));
						if (removee)
						{
							if (removee.parent && !_currentBounds.contains(col, row))
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

//map.put(WorldObject.createSpiro(0xff00ff, CELL_SIZE, CELL_SIZE), 0, 0);
//map.put(WorldObject.createSpiro(0x00ff00, CELL_SIZE, CELL_SIZE), 1, 1);
//map.put(WorldObject.createSpiro(0x0000ff, CELL_SIZE, CELL_SIZE), 2, 2);
//map.put(WorldObject.createSquare(0x0000ff, CELL_SIZE), 3, 3);
//return;			
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
					var wo:WorldObject = WorldObject.createSpiro(Math.random() * 0xffffff, CELL_SIZE, CELL_SIZE);
					Utils.addText(wo, "(" + loc.row + "," + loc.col + ")", 0xff0000).background = true;
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
