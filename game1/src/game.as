package 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
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

		private static const SPEED:uint = 7;
		private var _worldPosition:Point = new Point(0, 0);
		private var _lastWorldPosition:Point = new Point(-1, -1);
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

			if (!_lastWorldPosition.equals(_worldPosition))
			{
				renderMap();
				
				Utils.setPoint(_lastWorldPosition, _worldPosition);
			}
		}

		private var _lastMapBounds:Bounds = new Bounds;

		// [kja] premature optimization - these are kept around to avoid allocating them every frame 
		private var _currentMapBounds:Bounds = new Bounds;
		private var _worldPositionCellOffset:Point = new Point;
		private function renderMap():void
		{
			_player.x = stage.stageWidth/2;
			_player.y = stage.stageHeight/2;

			// determine the before/after of the world scene bounds
			_currentMapBounds.left = _worldPosition.x/CELL_SIZE;
			_currentMapBounds.right =  (_worldPosition.x + stage.stageWidth)/CELL_SIZE;
			
			_currentMapBounds.top = _worldPosition.y/CELL_SIZE;
			_currentMapBounds.bottom = (_worldPosition.y + stage.stageHeight)/CELL_SIZE;

//trace("currentBounds top", _currentMapBounds.top, "world y", _worldPosition.y, "stageHeight", stage.stageHeight);

			_worldPositionCellOffset.x = _worldPosition.x%CELL_SIZE;
			_worldPositionCellOffset.y = _worldPosition.y%CELL_SIZE;

			// loop through the objects in current bounds, setting their position, and adding
			// them to the stage if they're not yet there
			var slotX:uint;
			var slotY:uint;
			for (slotX = Math.max(0, _currentMapBounds.left); slotX <= _currentMapBounds.right; ++slotX)
			{
				for (slotY = Math.max(0, _currentMapBounds.top); slotY <= _currentMapBounds.bottom; ++slotY)
				{
					var wo:WorldObject = WorldObject(_map.lookup(slotX, slotY));
					if (wo)
					{
						wo.x = (slotX - _currentMapBounds.left) * CELL_SIZE - _worldPositionCellOffset.x;
						wo.y = (slotY - _currentMapBounds.top) * CELL_SIZE - _worldPositionCellOffset.y;
						if (!wo.parent)
						{
							parent.addChild(wo);
trace("adding", slotX, slotY);							
						}
					}
				}
			} 
			// loop through the objects of the last bounds, removing them if they're offscreen
			if (!_currentMapBounds.equals(_lastMapBounds))
			{
trace("bounds change", _lastMapBounds, "to", _currentMapBounds);
				const left:uint = Math.max(0, _lastMapBounds.left); 
				for (slotX = left; slotX <= _lastMapBounds.right; ++slotX)
				{
					for (slotY = Math.max(0, _lastMapBounds.top); slotY <= _lastMapBounds.bottom; ++slotY)
					{
						var removee:DisplayObject = DisplayObject(_map.lookup(slotX, slotY));
						if (removee)
						{
							if (removee.parent && !_currentMapBounds.contains(slotX, slotY))
							{
								removee.parent.removeChild(removee);
trace("removing", slotX, slotY);
							}
						}
					}
				} 
			}
			_lastMapBounds.setBounds(_currentMapBounds);
		}

		private static function debugcreate(map:Array2D, color:uint, x:uint, y:uint):void
		{
			var obj:DisplayObjectContainer = WorldObject.createSquare(color, CELL_SIZE);
			Utils.addText(obj, "(" + x + "," + y + ")", 0xff0000).background = true;
			map.put(obj, x, y);
		}
		private static function initMap(map:Array2D, densityPct:Number):void
		{
//map.put(WorldObject.createSpiro(0xff00ff, CELL_SIZE, CELL_SIZE), 0, 0);
//map.put(WorldObject.createSpiro(0x00ff00, CELL_SIZE, CELL_SIZE), 1, 1);
//map.put(WorldObject.createSpiro(0x0000ff, CELL_SIZE, CELL_SIZE), 2, 2);
//map.put(WorldObject.createSquare(0x0000ff, CELL_SIZE), 3, 3);
//return;
const colors:Array = [0xff0000, 0x00ff00, 0x0000ff];
for (var n:uint = 0; n < 12; ++n)
{
	debugcreate(map, colors[n % colors.length], 3, n);
}
return;			
			const XSLOTS:uint = map.width;
			const YSLOTS:uint = map.height;
			const count:uint = densityPct * (XSLOTS * YSLOTS);
			for (var i:uint = 0; i < count; ++i)
			{
				var loc:Location = findBlank(map, Math.random() * XSLOTS, Math.random() * YSLOTS);
				if (loc)
				{
					// [kja] we're using DisplayObjects in our actual map - the map instead should just be data,
					// and we instead simply pool DisplayObjects, reusing them as necessary.
					var wo:WorldObject = WorldObject.createSpiro(Math.random() * 0xffffff, CELL_SIZE, CELL_SIZE);
					textMarkIt(wo);
					map.put(wo, loc.x, loc.y);
				} 
			} 
		}
		
		private static function findBlank(map:Array2D, startX:uint, startY:uint):Location
		{
			while (startY < map.height)
			{
				if (!map.lookup(startX, startY))
				{
					return new Location(startX, startY);
				}
				if (++startX >= map.width)
				{
					startX = 0;
					++startY;
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
	public var x:int;
	public var y:int;
	public function Location(x:uint = 0, y:uint = 0)
	{
		setPos(x, y);
	}
	public function setPos(x:uint, y:uint):void
	{
		this.x = x;
		this.y = y;
	}
}
