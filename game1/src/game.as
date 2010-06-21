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
	import flash.utils.Timer;
	
	import karnold.tile.BitmapTileFactory;
	import karnold.tile.ITileFactory;
	import karnold.tile.TiledBackground;
	import karnold.utils.Array2D;
	import karnold.utils.Bounds;
	import karnold.utils.FrameRate;
	import karnold.utils.FrameTimer;
	import karnold.utils.Input;
	import karnold.utils.Location;
	import karnold.utils.Physics;
	import karnold.utils.Utils;

	// efficiency with the bitmaps was pretty goddamned sweet
	public final class game extends Sprite
	{
		private var _bg:TiledBackground;
		private var _worldBounds:Bounds;

		private var _input:Input;
		private var _player:DisplayObject;
		private var _playerPos:Point;
		private var _frameTimer:FrameTimer = new FrameTimer(onEnterFrame);
		private var _frameRate:FrameRate = new FrameRate;
		
		static private const VECTOR:Boolean = false;
		public function game()
		{
//			stage.align = StageAlign.TOP_LEFT;
//			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 40;
			stage.focus = stage;
			FrameTimer.init(stage);
			_frameTimer.startPerFrame();

			_input = new Input(stage);

			var factory:ITileFactory = VECTOR ? new DebugVectorTileFactory : new BitmapTileFactory(AssetManager.instance);

			_bg = new TiledBackground(this, factory, 40, 40, stage.stageWidth, stage.stageHeight);
			this.scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);

			_worldBounds =  new Bounds(0, 0, factory.tileSize * _bg.tilesArray.width, factory.tileSize*_bg.tilesArray.height);

			_playerPos = _worldBounds.middle;
			_player = DebugVectorObject.createSpaceship();//DebugVectorObject.createCircle(0xff0000, 20, 20);
			parent.addChild(_player);

			if (VECTOR)
			{
				initVectorMap(_bg, 0.2);
			}
			else
			{
				initRasterMap(_bg);
			}
			trace("stage", stage.stageWidth, stage.stageHeight);
			
			graphics.lineStyle(0, 0xff0000);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			mouseChildren = false;
			mouseEnabled = false;
		}

		private static const ACCELERATION:Number = 1;
		private static const MAX_SPEED:Number = 6;
		private static const SPEED_DECAY:Number = 0.1;  // percentage
		private var _speed:Point = new Point(0, 0);
		private var _actors:Array = [];
		private var _lastPlayerPos:Point = new Point;
		private var _cameraPos:Point = new Point;
		private var _lastCameraPos:Point = new Point;
		private function onEnterFrame():void
		{
			//
			// Check input
			if (_input.isKeyDown(Input.KEY_RIGHT))
			{
				_speed.x = Math.min(MAX_SPEED, _speed.x + ACCELERATION);
			}
			else if (_input.isKeyDown(Input.KEY_LEFT))
			{
				_speed.x = Math.max(-MAX_SPEED, _speed.x - ACCELERATION);
			}
			else if (_speed.x)
			{
				_speed.x = Physics.speedDecay(_speed.x, SPEED_DECAY);
			}
			
			if (_input.isKeyDown(Input.KEY_DOWN))
			{
				_speed.y = Math.min(MAX_SPEED, _speed.y + ACCELERATION);
			}
			else if (_input.isKeyDown(Input.KEY_UP))
			{
				_speed.y = Math.max(-MAX_SPEED, _speed.y - ACCELERATION);
			}
			else if (_speed.y)
			{
				_speed.y = Physics.speedDecay(_speed.y, SPEED_DECAY);
			}

			if (_input.checkKeyHistoryAndClear(Input.KEY_TILDE))
			{
				if (_frameRate.parent)
				{
					_frameRate.enabled = false;
					_frameRate.parent.removeChild(_frameRate);
				}
				else
				{
					_frameRate.enabled = true;
					parent.addChild(_frameRate);
				}
			}

			//
			// Render the background
			_playerPos.offset(_speed.x, _speed.y);

			Physics.constrain(_worldBounds, _playerPos, _player.width, _player.height, _speed);
			
			if (!_lastPlayerPos.equals(_playerPos))
			{
				Utils.setPoint(_lastPlayerPos, _playerPos);
				positionPlayerAndCamera();
				if (!_cameraPos.equals(_lastCameraPos))
				{
					Utils.setPoint(_lastCameraPos, _cameraPos);
					_bg.setCamera(_cameraPos);
				}
			}

			//TEST CODE
			if (_input.checkKeyHistoryAndClear(Input.MOUSE_BUTTON) || _input.checkKeyHistoryAndClear(Input.KEY_SPACE))
			{
				var actor:Actor = new Actor(DebugVectorObject.createCircle(0xff7777, 5, 5));
				actor.speed = _speed.clone();
				actor.worldPos = _playerPos.clone();
				_actors.push(actor);
				
				addChild(actor.displayObject);
			}
			
			for each (var a:Actor in _actors)
			{
				a.worldPos.offset(a.speed.x, a.speed.y);
				Physics.constrain(_worldBounds, a.worldPos, a.displayObject.width, a.displayObject.height, a.speed);
				a.speed.x = Physics.speedDecay(a.speed.x, 0.01);
				a.speed.y = Physics.speedDecay(a.speed.y, 0.01);
				
				a.displayObject.x = a.worldPos.x - _cameraPos.x;
				a.displayObject.y = a.worldPos.y - _cameraPos.y;
				
				a.displayObject.parent.setChildIndex(a.displayObject, a.displayObject.parent.numChildren-1);
			}
			//TEST CODE END
			
			_frameRate.txt1 = 3;stage.numChildren;
			_frameRate.txt2 = 3;this.numChildren;
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
			
			_player.rotation = Math.atan2(_speed.x, -_speed.y)/Math.PI * 180;
		}

/*
NEXT TASK:
	- put the scrolling 2D tiled background in a class
		- new tiled class will use/contain the map
		- it should act like an item renderer, NOT a diplayobject and able to render on your own surface
	- share it with the level editor
	- define level editor data (some custom xml format)
		<level>
			<tileset>ground</tileset>
			<tiles>0-0-0,0-1-2,0-2-0....</tiles>
		    <objects>234-212-0,....</objects>
		    <timeline>...</timeline>
		    ideally you'd have a script you could run... hmmm
				- script itself could be compiled actionscript
		</level>
		
*/
		
		private static function initRasterMap(bg:TiledBackground):void
		{
			bg.fromString(SampleData.level1);
		}
		private static function initVectorMap(bg:TiledBackground, densityPct:Number):void
		{
//for (var n:uint = 0; n < map.height; ++n)
//{
//		var obj:DisplayObjectContainer = DebugVectorObject.createSquare(color, 20);
//		Utils.addText(obj, "(" + x + "," + y + ")", 0xff0000).background = true;
//		map.put(obj, x, y);
//}
//return;			
			const XSLOTS:uint = bg.tilesArray.width;
			const YSLOTS:uint = bg.tilesArray.height;
			const count:uint = densityPct * (XSLOTS * YSLOTS);
			for (var i:uint = 0; i < count; ++i)
			{
				var loc:Location = findBlank(bg.tilesArray, Math.random() * XSLOTS, Math.random() * YSLOTS);
				if (loc)
				{
					// [kja] we're using DisplayObjects in our actual map - the map instead should just be data,
					// and we instead simply pool DisplayObjects, reusing them as necessary.
					bg.putTile(DebugVectorTileFactory.TILE_SPIRO, loc.x, loc.y);
//					Utils.addText(wo, "(" + loc.x + "," + loc.y + ")", 0xff0000).background = true;
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
import flash.geom.Point;

final class Actor
{
	public var displayObject:DisplayObject;
	public var speed:Point = new Point();
	public var worldPos:Point = new Point();
	public function Actor(dobj:DisplayObject)
	{
		displayObject = dobj;
	}
}

final class SampleData
{
	[Embed(source="assets/level1.txt", mimeType="application/octet-stream")]
	static private const Level1Data:Class;

	static public function get level1():String
	{
		return (new Level1Data).toString();
	}
}