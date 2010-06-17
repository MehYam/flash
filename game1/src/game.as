package 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import karnold.utils.Bounds;
	import karnold.utils.Keyboard;
	import karnold.utils.Utils;

	public final class game extends Sprite
	{
		// CELL_SIZE is in world coordinates, and currently world coordinates are pixels
		static private const CELL_SIZE:uint = 50;

		private var _tiles:Array2D = new Array2D(18, 20);
		private var _keyboard:Keyboard;
		private var _player:WorldObject;
		public function game()
		{
//			stage.align = StageAlign.TOP_LEFT;
//			stage.scaleMode = StageScaleMode.NO_SCALE;

			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			stage.focus = stage;

			_keyboard = new Keyboard(stage);
			
			_player = WorldObject.createCircle(0xff0000, 20, 20);
			parent.addChild(_player);

			initMap(_tiles, 0.2);
			trace("stage", stage.stageWidth, stage.stageHeight);
			
			graphics.lineStyle(0, 0xff0000);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		}

		private static const ACCELERATION:Number = 1;
		private static const MAX_SPEED:Number = 10;
		private static const SPEED_DECAY:Number = 0.1;  // percentage
		private var _speed:Point = new Point(0, 0);

		private const _worldBounds:Bounds = new Bounds(0, 0, CELL_SIZE*_tiles.width, CELL_SIZE*_tiles.height);

		private var _playerPos:Point = _worldBounds.middle;
		private var _lastPlayerPos:Point = new Point;
		private var _cameraPos:Point = new Point;
		private var _lastCameraPos:Point = new Point;
		private function onEnterFrame(_unused:Event):void
		{
			if (_keyboard.keys[Keyboard.KEY_RIGHT])
			{
				_speed.x = Math.min(MAX_SPEED, _speed.x + ACCELERATION);
			}
			else if (_keyboard.keys[Keyboard.KEY_LEFT])
			{
				_speed.x = Math.max(-MAX_SPEED, _speed.x - ACCELERATION);
			}
			else if (_speed.x)
			{
				_speed.x = Physics.speedDecay(_speed.x, SPEED_DECAY);
			}
			
			if (_keyboard.keys[Keyboard.KEY_DOWN])
			{
				_speed.y = Math.min(MAX_SPEED, _speed.y + ACCELERATION);
			}
			else if (_keyboard.keys[Keyboard.KEY_UP])
			{
				_speed.y = Math.max(-MAX_SPEED, _speed.y - ACCELERATION);
			}
			else if (_speed.y)
			{
				_speed.y = Physics.speedDecay(_speed.y, SPEED_DECAY);
			}

			_playerPos.offset(_speed.x, _speed.y);

			Physics.constrain(_worldBounds, _playerPos, _player.width, _player.height, _speed);

			if (!_lastPlayerPos.equals(_playerPos))
			{
				Utils.setPoint(_lastPlayerPos, _playerPos);
				positionPlayerAndCamera();
				if (!_cameraPos.equals(_lastCameraPos))
				{
					Utils.setPoint(_lastCameraPos, _cameraPos);
					renderMap(_cameraPos);
				}
			}
		}

		private function positionPlayerAndCamera():void
		{
			const stageMiddleHorz:Number = stage.stageWidth/2;
			const stageMiddleVert:Number = stage.stageHeight/2;
			
			_cameraPos.x = _playerPos.x - stageMiddleHorz;
			_cameraPos.y = _playerPos.y - stageMiddleVert;
			
			_player.x = stageMiddleHorz;
			_player.y = stageMiddleVert;
			if (_cameraPos.x < _worldBounds.left)
			{
				_player.x -= (_worldBounds.left - _cameraPos.x);
				_cameraPos.x = _worldBounds.left;
			}
			else 
			{
				const cameraRightBound:Number = _worldBounds.right - stage.stageWidth; 
				if (_cameraPos.x > cameraRightBound)
				{
					_player.x += _cameraPos.x - cameraRightBound;
					_cameraPos.x = cameraRightBound;
				}
			}
			if (_cameraPos.y < _worldBounds.top)
			{
				_player.y -= (_worldBounds.top - _cameraPos.y);
				_cameraPos.y = _worldBounds.top; 
			}
			else
			{
				const cameraBottomBound:Number = _worldBounds.bottom - stage.stageHeight;
				if (_cameraPos.y > cameraBottomBound)
				{
					_player.y += _cameraPos.y - cameraBottomBound;
					_cameraPos.y = cameraBottomBound;
				}
			}
		}

		// [kja] premature optimization - these are kept around to avoid allocating them every frame
		// all premature optimization is marked as po_
		private var po_currentMapBounds:Bounds = new Bounds;
		private var po_cellOffset:Point = new Point;
		private var _lastMapBounds:Bounds = new Bounds;
		private function renderMap(cameraPos:Point):void
		{
			// determine the before/after of the world scene bounds
			po_currentMapBounds.left = cameraPos.x/CELL_SIZE;
			po_currentMapBounds.right = (cameraPos.x + stage.stageWidth)/CELL_SIZE;
			
			po_currentMapBounds.top = cameraPos.y/CELL_SIZE;
			po_currentMapBounds.bottom = (cameraPos.y + stage.stageHeight)/CELL_SIZE;

			po_cellOffset.x = cameraPos.x%CELL_SIZE;
			po_cellOffset.y = cameraPos.y%CELL_SIZE;

			// loop through the objects in current bounds, setting their position, and adding
			// them to the stage if they're not yet there
			var slotX:uint;
			var slotY:uint;
			for (slotX = Math.max(0, po_currentMapBounds.left); slotX <= po_currentMapBounds.right; ++slotX)
			{
				for (slotY = Math.max(0, po_currentMapBounds.top); slotY <= po_currentMapBounds.bottom; ++slotY)
				{
					var wo:WorldObject = WorldObject(_tiles.lookup(slotX, slotY));
					if (wo)
					{
						wo.x = (slotX - po_currentMapBounds.left) * CELL_SIZE - po_cellOffset.x;
						wo.y = (slotY - po_currentMapBounds.top) * CELL_SIZE - po_cellOffset.y;
						if (!wo.parent)
						{
							addChild(wo);
							trace("adding", slotX, slotY);							
						}
					}
				}
			} 
			// loop through the objects of the last bounds, removing them if they're offscreen
			if (!po_currentMapBounds.equals(_lastMapBounds))
			{
				trace("bounds change", _lastMapBounds, "to", po_currentMapBounds);
				const left:uint = Math.max(0, _lastMapBounds.left); 
				for (slotX = left; slotX <= _lastMapBounds.right; ++slotX)
				{
					for (slotY = Math.max(0, _lastMapBounds.top); slotY <= _lastMapBounds.bottom; ++slotY)
					{
						var removee:DisplayObject = DisplayObject(_tiles.lookup(slotX, slotY));
						if (removee)
						{
							if (removee.parent && !po_currentMapBounds.contains(slotX, slotY))
							{
								removee.parent.removeChild(removee);
								trace("removing", slotX, slotY);
							}
						}
					}
				} 
			}
			_lastMapBounds.setBounds(po_currentMapBounds);
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
//const colors:Array = [0xff0000, 0x00ff00, 0x0000ff];
//for (var n:uint = 0; n < map.height; ++n)
//{
//	debugcreate(map, colors[n % colors.length], 3, n);
//}
//return;			
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
					Utils.addText(wo, "(" + loc.x + "," + loc.y + ")", 0xff0000).background = true;
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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import karnold.utils.Bounds;

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

final class Physics
{
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
}